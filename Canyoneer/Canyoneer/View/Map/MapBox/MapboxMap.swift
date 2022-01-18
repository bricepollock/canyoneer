//
//  MapBoxMap.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/14/22.
//

import Foundation
import UIKit
import CoreLocation
import RxSwift
import MapboxMaps

class MapboxMapView: NSObject, CanyonMap {
    public var locationService = LocationService()
    
    private var mapView: MapView!
    public var view: UIView {
        if self.mapView == nil {
            let myResourceOptions = ResourceOptions(accessToken: MapService.publicAccessToken)
            let myMapInitOptions = MapInitOptions(
                resourceOptions: myResourceOptions,
                styleURI: StyleURI.outdoors
            )
            self.mapView = MapView(frame: UIScreen.main.bounds, mapInitOptions: myMapInitOptions)
        }
        return self.mapView
    }
    
    public let didRequestCanyon: RxSwift.Observable<String>
    private let didRequestCanyonSubject: PublishSubject<String>
    
    private var mapOverlays = [PolylineAnnotation]()
    
    override init() {
        self.didRequestCanyonSubject = PublishSubject()
        self.didRequestCanyon = self.didRequestCanyonSubject.asObservable()
        super.init()
    }
    
    var visibleCanyons: [Canyon] {
        fatalError("Not implemented")
    }
    
    func initialize() {
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let annotationManager = self.mapView.annotations.makePointAnnotationManager()
        annotationManager.delegate = self
        
        if locationService.isLocationEnabled() {
            // Add user position icon to the map with location indicator layer
            mapView.location.options.puckType = .puck2D()
        }
    }
    
    func renderAnnotations(canyons: [Canyon]) {
        let annotationManager = self.mapView.annotations.makePointAnnotationManager()
        annotationManager.annotations = canyons.map {
            let point = Point($0.coordinate.asCLObject)
            var annotation = PointAnnotation(point: point)
            let image = UIImage(systemName: "pin.fill")!.withTintColor(ColorPalette.Color.warning, renderingMode: .alwaysOriginal)
            annotation.image = .init(image: image, name: "red_pin")
            annotation.textField = $0.name
            annotation.iconAnchor = .bottom
            annotation.userInfo = ["canyon": $0]
            return annotation
        }
    }
    
    func removeAnnotations() {
        let annotationManager = self.mapView.annotations.makePointAnnotationManager()
        annotationManager.annotations = []
    }
    
    func renderPolylines(canyons: [Canyon]) {
        let lineManager = self.mapView.annotations.makePolylineAnnotationManager()
        let overlays = canyons.flatMap { canyon in
            return canyon.geoLines.map { feature -> PolylineAnnotation in
                var overlay = PolylineAnnotation(lineCoordinates: feature.coordinates.map { $0.asCLObject })
                let type = TopoLineType(string: feature.name)
                let geoColor: UIColor?
                if let stroke = feature.hexColor {
                    geoColor = UIColor.hex(stroke)
                } else {
                    geoColor = nil
                }
                let color = type == .unknown ? geoColor ?? type.color : type.color
                overlay.lineColor = StyleColor(color)
                overlay.lineWidth = 3
                overlay.lineOpacity = 0.5
                return overlay
            }
        }
        self.mapOverlays = overlays
        lineManager.annotations = overlays
    }
    
    func renderPolylinesFromCache() {
        let lineManager = self.mapView.annotations.makePolylineAnnotationManager()
        guard lineManager.annotations.isEmpty else {
            return // we already added the overlays
        }
        lineManager.annotations = self.mapOverlays
    }
    
    func removePolylines() {
        let lineManager = self.mapView.annotations.makePolylineAnnotationManager()
        lineManager.annotations = []
    }
    
    func renderWaypoints(canyon: Canyon) {
        let annotationManager = self.mapView.annotations.makePointAnnotationManager()
        // add waypoints from map
        let waypoints = canyon.geoWaypoints.map { feature -> PointAnnotation in
            let point = Point(feature.coordinates[0].asCLObject)
            var annotation = PointAnnotation(point: point)
            let image = UIImage(systemName: "pin.fill")!.withTintColor(ColorPalette.Color.warning, renderingMode: .alwaysOriginal)
            annotation.image = .init(image: image, name: "red_pin")
            annotation.textField = feature.name
            annotation.iconAnchor = .bottom
            return annotation
        }
        
        
        // add labels for the lines
        let labels = canyon.geoLines.compactMap { feature -> PointAnnotation? in
            if let first = feature.coordinates.first {
                let point = Point(first.asCLObject)
                var annotation = PointAnnotation(point: point)
                annotation.textField = feature.name
                annotation.iconAnchor = .bottom
                return annotation
            } else {
                return nil
            }
        }
        annotationManager.annotations = waypoints + labels
    }
    
    func focusCameraOn(canyon: Canyon) {
        let center = canyon.coordinate.asCLObject
        self.mapView.mapboxMap.setCamera(to: CameraOptions(center: center, zoom: 11))
    }
    
    func focusCameraOn(location: CLLocationCoordinate2D) {
        self.mapView.mapboxMap.setCamera(to: CameraOptions(center: location, zoom: 8))
    }
}

extension MapboxMapView: AnnotationInteractionDelegate {
    public func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard let first = annotations.first, let canyon = first.userInfo?["canyon"] as? Canyon else {
            Global.logger.error("Cannot find canyon from annotation")
            return
        }
        self.didRequestCanyonSubject.onNext(canyon.id)
    }
}
