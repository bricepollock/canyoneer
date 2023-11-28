//
//  AppleMapView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import MapKit
import Combine

class AppleMapView: NSObject, CanyonMap {
    public var locationService = LocationService()
    
    private let mapView = MKMapView()
    public var view: UIView {
        return mapView
    }
    
    let didRequestCanyon = PassthroughSubject<String, Never>()
    
    private var mapOverlays = [MKOverlay]()
    private var headingView: UIView?
    private var bag = Set<AnyCancellable>()
    
    public var visibleCanyons: [Canyon] {
        return self.mapView.visibleAnnotations().compactMap {
            return ($0 as? CanyonAnnotation)?.canyon
        }
    }
    
    public func initialize() {
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        
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
    
    public func renderAnnotations(canyons: [Canyon]) {
        canyons.forEach { canyon in
            let annotation = CanyonAnnotation(canyon: canyon)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    public func removeAnnotations() {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    public func renderPolylines(canyons: [Canyon]) {
        let topoLines = canyons.flatMap { canyon in
            return canyon.geoLines
                .map { feature -> TopoLineOverlay in
                    let overlay = TopoLineOverlay(coordinates: feature.coordinates.map { $0.asCLObject }, count: feature.coordinates.count)
                    overlay.name = feature.name
                    
                    // This color will be overriden by the type.color
                    if let hex = feature.hexColor {
                        overlay.color = UIColor.hex(hex)
                    }
                    return overlay
                }
            }
        
        // Instead of adding each polyline individually, we group them together to try to get better performance on the map renderer even though its less performant to do this here
        let multiPolylineOverlays = TopoLineType.allCases.map { type in
            TopoLineLayer(
                name: type.rawValue,
                type: type,
                polylines: topoLines.filter { $0.type == type }
            )
        }
        
        self.mapOverlays = multiPolylineOverlays
        multiPolylineOverlays.forEach {
            self.mapView.addOverlay($0)
        }
    }
    
    public func renderPolylinesFromCache() {
        guard self.mapView.overlays.isEmpty else {
            return // we already added the overlays
        }
        self.mapOverlays.forEach {
            self.mapView.addOverlay($0)
        }
    }
    
    public func removePolylines() {
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    public func renderWaypoints(canyon: Canyon) {
        let waypoints = canyon.geoWaypoints.map { feature in
            return WaypointAnnotation(feature: feature)
        }
        waypoints.forEach { annotation in
            self.mapView.addAnnotation(annotation)
        }
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

extension AppleMapView: MKMapViewDelegate {
 
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
            self.headingView = headingView
            headingView.constrain.height(20)
            headingView.constrain.aspect(1)
            
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
            annotationView.insertSubview(headingView, at: 0)
            return annotationView
            
        }
        return NonClusteringMKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let layerMultiPolyline = overlay as? TopoLineLayer {
            let renderer = MKMultiPolylineRenderer(multiPolyline: layerMultiPolyline)
            renderer.strokeColor = layerMultiPolyline.type.color
            renderer.lineWidth = 3
            return renderer
        }

        return MKOverlayRenderer()
    }
}
