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
    
    public var center: CLLocationCoordinate2D {
        mapView.mapboxMap.cameraState.center
    }
    
    @Published var zoomLevel: Double = 0
    /// The coordinate bounds of the visible map
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
            circleRadius: .constant(24),
            circleColor: .constant(StyleColor(UIColor(ColorPalette.Color.canyonRed))),
            textSize: .constant(18),
            clusterMaxZoom: Self.zoomLevelThresholdForTopoLines
        )
        self.canyonPinManager = mapView.annotations.makePointAnnotationManager(id: "canyon-pins", clusterOptions: clusterOptions)
        
        // Hide text if it collides with other text (it will still show if collide with icon, so there is still some overlapping)
        self.canyonPinManager.textAllowOverlap = false
        self.canyonPinManager.iconAllowOverlap = true
        self.canyonPinManager.textIgnorePlacement = false
        self.canyonPinManager.iconIgnorePlacement = false
        self.canyonPinManager.textOptional = true
        
        // Do same for waypoints
        self.waypointManager.textAllowOverlap = false
        self.waypointManager.iconAllowOverlap = true
        self.waypointManager.textIgnorePlacement = false
        self.waypointManager.iconIgnorePlacement = false
        self.waypointManager.textOptional = true
    }
}

extension MapboxMapViewModel: BasicMap {
    func initialize() {
        if locationService.isLocationEnabled() {

            // Used "location.north.fill" image but SF Symbols didn't work here needed a bundled asset
            let heading = UIImage(named: "map_location_heading")!            
            let puckConfig = Puck2DConfiguration(
                topImage: heading,
                scale: .constant(0.25)
            )
            
            // Add user location icon with heading direction
            mapView.location.options.puckType = .puck2D(puckConfig)
            mapView.location.options.puckBearing = .heading
            mapView.location.options.puckBearingEnabled = true
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
    
    func focusCameraOn(canyon: Canyon, animate: Bool) {
        let center = canyon.coordinate.asCLObject
        let cameraDetails = CameraOptions(center: center, zoom: 11)
        if animate {
            self.mapView.camera.ease(to: cameraDetails, duration: 0.5)
        } else {
            self.mapView.mapboxMap.setCamera(to: cameraDetails)
        }
    }
    
    func focusCameraOn(location: CLLocationCoordinate2D, animate: Bool) {
        let cameraDetails = CameraOptions(center: location, zoom: 8)
        if animate {
            self.mapView.camera.ease(to: cameraDetails, duration: 0.5)
        } else {
            self.mapView.mapboxMap.setCamera(to: cameraDetails)
        }
    }
}
