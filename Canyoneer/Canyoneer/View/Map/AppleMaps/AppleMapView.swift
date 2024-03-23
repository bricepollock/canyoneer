//
//  AppleMapView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import MapKit
import SwiftUI
import UIKit
import Combine

class AppleMapViewOwner: NSObject {
    public let view: AnyUIKitView
    private let mapView: MKMapView
    
    let didRequestCanyon = PassthroughSubject<String, Never>()

    public let locationService: LocationService
    /// A map of canyons to overlays
    private var mapOverlays = [String: [TopoLineLayer]]()
    private var headingView: UIView?
    private var bag = Set<AnyCancellable>()
    private let canyonManager: CanyonDataManaging
    
    init(locationService: LocationService = LocationService(), canyonManager: CanyonDataManaging) {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        self.mapView = mapView
        self.view = AnyUIKitView(view: mapView)
        self.locationService = locationService
        self.canyonManager = canyonManager
        super.init()
        // -- init -- //
        
        mapView.delegate = self
    }
    
    public var visibleCanyons: [CanyonIndex] {
        return self.mapView.visibleAnnotations().compactMap {
            return ($0 as? CanyonAnnotation)?.canyon
        }
    }
    
    public var currentCanyons: [CanyonIndex] {
        return self.mapView.annotations.compactMap {
            return ($0 as? CanyonAnnotation)?.canyon
        }
    }
    
    public func addAnnotations(for canyons: [CanyonIndex]) {
        canyons.forEach { canyon in
            let annotation = CanyonAnnotation(canyon: canyon)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    public func removeAnnotations(for canyonMap: [String: CanyonIndex]) {
        let annotationsToRemove = self.mapView.annotations
            .compactMap { $0 as? CanyonAnnotation }
            .filter { annotation in
                canyonMap[annotation.canyon.id] != nil
            }
        self.mapView.removeAnnotations(annotationsToRemove)
    }
    
    public func removeAnnotations() {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    public func deselectCanyons() {
        self.mapView.selectedAnnotations.forEach {
            self.mapView.deselectAnnotation($0, animated: false)
        }
    }
    
    // FIXME: [ISSUE-6] Several things are needed to get polylines back on main map
    // * We need the ability to determine zoom level (not easy in MKMapView) so we only client-render at certain levels to prevent overwhelming memory overhead
    // * We need ability to determine which canyons are in current view port so that we only get the large GPX objects for those canyons
    public func renderCanyonPolylinesOnMap() async throws {
        let isTightEnoughZoomToShowOnMap = false
        guard isTightEnoughZoomToShowOnMap else {
            return
        }
        
        let canyonsVisibleInViewport = [CanyonIndex]()
        try await renderPolylines(for: canyonsVisibleInViewport)
        
    }
    
    public func renderPolylinesFromCache() {
        guard self.mapView.overlays.isEmpty else {
            return // we already added the overlays
        }
        self.mapOverlays.values
            .flatMap {
                $0
            }.forEach {
                self.mapView.addOverlay($0)
            }
    }
    
    public func removePolylines(for canyons: [CanyonIndex]) {
        let overlaysToRemove = canyons.compactMap {
            mapOverlays[$0.id]
        }.flatMap { $0 }
        self.mapView.removeOverlays(overlaysToRemove)
        canyons.forEach {
            mapOverlays[$0.id] = nil
        }
    }
    
    public func removeAllPolylines() {
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    @MainActor private func renderPolylines(for canyons: [CanyonIndex]) async throws {
        // Get all canyon topos from disk
        let fullCanyons = try await withThrowingTaskGroup(of: Canyon.self) { group in
            canyons.forEach { canyon in
                _ = group.addTaskUnlessCancelled { [weak self] in
                    guard let self else {
                        throw GeneralError.unknownFailure
                    }
                    do {
                        return try await canyonManager.canyon(for: canyon.id)
                    } catch {
                        let errorMessage: String = "Failed to get canyon for \(canyon.id): \(error)"
                        Global.logger.error("\(errorMessage)")
                        throw error
                    }
                }
            }
            
            var responses = [Canyon]()
            for try await canyon in group {
                responses.append(canyon)
            }
            return responses
        }
        
        var canyonsToUpdate = [String: [TopoLineLayer]]()
        fullCanyons.forEach { canyon in
            canyonsToUpdate[canyon.id] = layers(from: canyon)
        }
        
        canyonsToUpdate.forEach { id, overlays in
            overlays.forEach {
                self.mapView.addOverlay($0)
            }
            mapOverlays[id] = overlays
        }
    }
    
    private func layers(from canyon: Canyon) -> [TopoLineLayer] {
        // Get all lines
        let topoLines = canyon.geoLines
            .map { feature -> TopoLineOverlay in
                let overlay = TopoLineOverlay(coordinates: feature.coordinates.map { $0.asCLObject }, count: feature.coordinates.count)
                overlay.name = feature.name
                
                // This color will be overriden by the type.color
                if let hex = feature.hexColor {
                    overlay.color = UIColor.hex(hex)
                }
                return overlay
            }
        
        // Instead of adding each polyline individually, we group them together to try to get better performance on the map renderer even though its less performant to do this here
        return TopoLineType.allCases.compactMap { type in
            let linesForLayer = topoLines.filter { $0.type == type }
            guard linesForLayer.isEmpty == false else { return nil }
            return TopoLineLayer(
                name: type.rawValue,
                type: type,
                polylines: linesForLayer
            )
        }
    }
}

extension AppleMapViewOwner: BasicMap {
    public func initialize() {
        self.locationService.$heading
            .compactMap { $0 }
            .sink { [weak self] newHeading in
            if newHeading.headingAccuracy < 0 { return }
            let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
            if let headingView = self?.headingView {
                let rotation = CGFloat(heading/180 * Double.pi)
                headingView.transform = CGAffineTransform(rotationAngle: rotation)
            }
        }.store(in: &self.bag)
    }
    
    public func focusCameraOn(canyon: Canyon) {
        let center = canyon.coordinate.asCLObject
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.mapView.setRegion(region, animated: true)
    }
    
    public func focusCameraOn(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        self.mapView.setRegion(region, animated: true)
    }
}

extension AppleMapViewOwner: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let defaultCenter = CLLocationCoordinate2D(latitude: 37.13284, longitude: -95.78558)
        if defaultCenter.distance(to: mapView.camera.centerCoordinate) > 0.1 {
            UserDefaults.standard.setLastViewCoordinate(mapView.camera.centerCoordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let mkAnnotation = view.annotation, let annotation = mkAnnotation as? CanyonAnnotation else {
            return
        }
        self.didRequestCanyon.send(annotation.canyon.id)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation.title != "My Location" else {
            let image = UIImage(systemName: "location.north.fill")!
            let headingView = UIImageView(image: image)
            headingView.translatesAutoresizingMaskIntoConstraints = false
            
            self.headingView = headingView
            headingView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            headingView.widthAnchor.constraint(equalTo: headingView.heightAnchor).isActive = true
            
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
            annotationView.insertSubview(headingView, at: 0)
            return annotationView
            
        }
        return NonClusteringMKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let layerMultiPolyline = overlay as? TopoLineLayer {
            let renderer = MKMultiPolylineRenderer(multiPolyline: layerMultiPolyline)
            renderer.strokeColor = UIColor(layerMultiPolyline.type.color)
            renderer.lineWidth = 3
            return renderer
        }

        return MKOverlayRenderer()
    }
}
