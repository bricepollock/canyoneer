//
//  MapBoxMap.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/14/22.
//

import Foundation
import UIKit
import CoreLocation
import MapboxMaps
import Combine

extension Point {
    func isClose(to point: Point, proximity: Double = 2) -> Bool {
        let precision: Double = 1000
        let selfCloseLat = (self.coordinates.latitude * precision).rounded(.toNearestOrAwayFromZero)
        let selfCloseLong = (self.coordinates.longitude * precision).rounded(.toNearestOrAwayFromZero)
        let pointCloseLat = (point.coordinates.latitude * precision).rounded(.toNearestOrAwayFromZero)
        let pointCloseLong = (point.coordinates.longitude * precision).rounded(.toNearestOrAwayFromZero)
        return abs(selfCloseLat - pointCloseLat) <= proximity && abs(selfCloseLong - pointCloseLong) <= proximity
    }
}

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
    
    let didRequestCanyon = PassthroughSubject<String, Never>()
    
    private var mapOverlays = [PolylineAnnotation]()
    
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
        var waypoints: [PointAnnotation] = []
        canyon.geoWaypoints.forEach { feature in
            // all waypoints should have one coordinate
            guard let first = feature.coordinates.first else {
                return
            }
            let point = Point(first.asCLObject)
            
            // avoid any waypoints that overlap with others
            if waypoints.contains(where: { $0.point.isClose(to: point, proximity: 1) }) == true {
                return
            }
            
            var annotation = PointAnnotation(point: point)
            let image = UIImage(systemName: "pin.fill")!.withTintColor(ColorPalette.Color.warning, renderingMode: .alwaysOriginal)
            annotation.image = .init(image: image, name: "red_pin")
            annotation.textField = feature.name
            annotation.iconAnchor = .bottom
            waypoints.append(annotation)
        }
        
        // if no waypoints throw the canyon on there
        if waypoints.isEmpty {
            let point = Point(canyon.coordinate.asCLObject)
            var annotation = PointAnnotation(point: point)
            let image = UIImage(systemName: "pin.fill")!.withTintColor(ColorPalette.Color.warning, renderingMode: .alwaysOriginal)
            annotation.image = .init(image: image, name: "red_pin")
            annotation.textField = canyon.name
            annotation.iconAnchor = .bottom
            waypoints.append(annotation)
        }
        
        // add labels for the lines
        let labels = canyon.geoLines.compactMap { feature -> PointAnnotation? in
            // find a coordinate away from waypoints to label the polyline
            var coordinates = feature.coordinates
            var first: Coordinate? = coordinates.first
            while let found = first {
                let point = Point(found.asCLObject)
                // if our line coordinate is far from other waypoints, then use it
                if waypoints.contains(where: { $0.point.isClose(to: point) }) == false{
                    break
                }
                coordinates = Array(coordinates.dropFirst())
                first = coordinates.first
            }
            // if couldn't find a coordinate away from waypoints then skip this label
            guard let labelCoordinate = first else {
                return nil
            }
            let labelPoint = Point(labelCoordinate.asCLObject)
            var annotation = PointAnnotation(point: labelPoint)
            annotation.textField = feature.name
            annotation.iconAnchor = .center
            return annotation
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
        self.didRequestCanyon.send(canyon.id)
    }
}
