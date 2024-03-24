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

struct MapboxMapView: UIViewControllerRepresentable {
    let viewModel: MapboxMapViewModel
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return MapboxMapViewController(controller: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

/// - Warning: Cannot be interact with until `appear` since it relies the SwiftUI-UIKit bridge and in `Mapbox.v11` SwiftUI support is still experimental
class MapboxMapViewModel: NSObject {
    internal var mapView: MapboxMaps.MapView!
    
    @Published var zoomLevel: Double = 0
    @Published var visibleMap: CoordinateBounds = .zero
    let didRequestCanyon = PassthroughSubject<CanyonIndex, Never>()
    
    internal var canyonLineManager: PolylineAnnotationManager!
    internal var waypointManager: PointAnnotationManager!
    internal var canyonLabelManager: PointAnnotationManager!
    internal var canyonPinManager: PointAnnotationManager!
    internal var cachedPolylines: [PolylineAnnotation] = []
    
    internal let locationService: LocationService
    private var bag = Set<AnyCancellable>()
    
    init(locationService: LocationService = LocationService()) {
        self.locationService = locationService
    }
    
    func removeAllPolylines() {
        canyonLineManager.annotations = []
    }
}

extension MapboxMapViewModel: MapboxMapController {
    func didLoad(mapView: MapView) {
        self.mapView = mapView

        self.zoomLevel = Double(mapView.mapboxMap.cameraState.zoom)
        self.visibleMap = mapView.mapboxMap.cameraBounds.bounds
        
        self.canyonLineManager = mapView.annotations.makePolylineAnnotationManager(id: "canyon-lines")
        self.waypointManager = mapView.annotations.makePointAnnotationManager(id: "canyon-waypoints")
        self.canyonLabelManager = mapView.annotations.makePointAnnotationManager(id: "canyon-labels")
        self.canyonPinManager = mapView.annotations.makePointAnnotationManager(id: "canyon-pins")
    }
}

extension MapboxMapViewModel: BasicMap {
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
