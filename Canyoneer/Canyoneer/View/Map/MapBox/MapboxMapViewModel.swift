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
    public static let zoomLevelThresholdForTopoLines: Double = 9.9
    internal var mapView: MapboxMaps.MapView!
    
    @Published var zoomLevel: Double = 0
    @Published var visibleMap: CoordinateBounds = .zero
    /// The coordinate-area we want to render within (has an additional buffer around visibleMap)
    @Published var renderingBounds: CoordinateBounds = .zero
    let didRequestCanyon = PassthroughSubject<CanyonIndex, Never>()
    
    internal var canyonLineManager: PolylineAnnotationManager!
    internal var waypointManager: PointAnnotationManager!
    internal var canyonLabelManager: PointAnnotationManager!
    internal var canyonPinManager: PointAnnotationManager!
    internal var cachedPolylines: [PolylineAnnotation] = []
    
    internal let locationService: LocationService
    internal var bag = Set<AnyCancellable>()
    
    init(locationService: LocationService = LocationService()) {
        self.locationService = locationService
    }
    
    var visibleCoordinateBounds: CoordinateBounds {
        mapView.mapboxMap.coordinateBounds(for: CameraOptions(cameraState: mapView.mapboxMap.cameraState))
    }
    
    /// Applies a buffer around rect so if we are using it to render on the map then we have less stuff loading dynamically and it looks smooth like everything is just there
    var visibleCoordinateBoundsWithBuffer: CoordinateBounds {
        let bounds = mapView.bounds
        let buffer = bounds.width
        let expandedBounds = CGRect(
            origin: CGPoint(x: bounds.origin.x - buffer, y: bounds.origin.y - buffer),
            size: CGSize(width: bounds.width + 2*buffer, height: bounds.height + 2*buffer)
        )
        // This is working really well, but we still get flashing
        return mapView.mapboxMap.coordinateBounds(for: expandedBounds)
    }
}

extension MapboxMapViewModel: MapboxMapController {
    func didLoad(mapView: MapView) {
        self.mapView = mapView
        mapView.ornaments.compassView.isHidden = true

        self.zoomLevel = Double(mapView.mapboxMap.cameraState.zoom)
        self.visibleMap = visibleCoordinateBounds
        self.renderingBounds = visibleCoordinateBoundsWithBuffer
        
        self.canyonLineManager = mapView.annotations.makePolylineAnnotationManager(id: "canyon-lines")
        
        self.waypointManager = mapView.annotations.makePointAnnotationManager(id: "canyon-waypoints")
        self.canyonLabelManager = mapView.annotations.makePointAnnotationManager(id: "canyon-labels")
        
        let clusterOptions = ClusterOptions(
            circleColor: .constant(StyleColor(UIColor(ColorPalette.Color.canyonRed))),
            clusterMaxZoom: Self.zoomLevelThresholdForTopoLines
        )
        self.canyonPinManager = mapView.annotations.makePointAnnotationManager(id: "canyon-pins", clusterOptions: clusterOptions)

        // These seem to have no affect right now
//        self.canyonPinManager.textAllowOverlap = false
//        self.canyonPinManager.iconAllowOverlap = true
//        self.canyonPinManager.textOptional = true
        
        // Debug test code
//        setupDropPinAtCameraCenter()
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
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] cameraChanged in
            guard let self else { return }
            self.zoomLevel = Double(cameraChanged.cameraState.zoom)
            self.visibleMap = self.visibleCoordinateBounds
            self.renderingBounds = self.visibleCoordinateBoundsWithBuffer
        }.store(in: &bag)
    }
    
    func focusCameraOn(canyon: Canyon) {
        let center = canyon.coordinate.asCLObject
        self.mapView.mapboxMap.setCamera(to: CameraOptions(center: center, zoom: 11))
    }
    
    func focusCameraOn(location: CLLocationCoordinate2D) {
        self.mapView.mapboxMap.setCamera(to: CameraOptions(center: location, zoom: 8))
    }
}
