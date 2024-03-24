//
//  MapBoxMap.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/14/22.
//

import Foundation
import UIKit
import SwiftUI
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

class MapboxMap: NSObject {
    public let view: AnyUIKitView
    internal let mapView: MapboxMaps.MapView
    
    @Published var zoomLevel: Double
    @Published var visibleMap: CoordinateBounds
    let didRequestCanyon = PassthroughSubject<CanyonIndex, Never>()
    
    internal let canyonLineManager: PolylineAnnotationManager
    internal let waypointManager: PointAnnotationManager
    internal let canyonLabelManager: PointAnnotationManager
    internal let canyonPinManager: PointAnnotationManager
    internal var cachedPolylines: [PolylineAnnotation] = []
    
    internal let locationService: LocationService
    private var bag = Set<AnyCancellable>()
    
    init(locationService: LocationService = LocationService()) {
        let myMapInitOptions = MapInitOptions(
            styleURI: StyleURI.outdoors
        )
        let mapboxMapView = MapboxMaps.MapView(frame: UIScreen.main.bounds, mapInitOptions: myMapInitOptions)
        mapboxMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView = mapboxMapView
        self.zoomLevel = Double(mapboxMapView.mapboxMap.cameraState.zoom)
        self.visibleMap = mapboxMapView.mapboxMap.cameraBounds.bounds
        
        canyonLineManager = mapboxMapView.annotations.makePolylineAnnotationManager(id: "canyon-lines")
        waypointManager = mapboxMapView.annotations.makePointAnnotationManager(id: "canyon-waypoints")
        canyonLabelManager = mapboxMapView.annotations.makePointAnnotationManager(id: "canyon-labels")
        canyonPinManager = mapboxMapView.annotations.makePointAnnotationManager(id: "canyon-pins")
        
        self.view = AnyUIKitView(view: mapView)
        self.locationService = locationService
    }
    
    func removeAllPolylines() {
        canyonLineManager.annotations = []
    }
}

extension MapboxMap: BasicMap {
    func initialize() {
        if locationService.isLocationEnabled() {
            // Add user position icon to the map with location indicator layer
            mapView.location.options.puckType = .puck2D()
        }
        
        // Accuracy ring is only shown when zoom is greater than or equal to 18.
        mapView.mapboxMap.onCameraChanged
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] cameraChanged in
            guard let self else { return }
            self.zoomLevel = Double(cameraChanged.cameraState.zoom)
            self.visibleMap = self.mapView.mapboxMap.cameraBounds.bounds
        }.store(in: &bag)
    }
    
    func focusCameraOn(canyon: Canyon) {
        let center = canyon.coordinate.asCLObject
        self.mapView.mapboxMap.setCamera(to: CameraOptions(center: center, zoom: 11))
    }
    
    func focusCameraOn(location: CLLocationCoordinate2D) {
        self.mapView.mapboxMap.setCamera(to: CameraOptions(center: location, zoom: 8))
    }
    
    internal func makePointAnnotation(for canyon: CanyonIndex) -> PointAnnotation {
        var annotation = PointAnnotation(canyon: canyon)
        annotation.tapHandler = { [weak self] _ in
            self?.didRequestCanyon.send(canyon)
            return true
        }
        return annotation
    }
}
