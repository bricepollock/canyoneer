//
//  MapView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import UIKit
import CoreLocation
import Combine

@MainActor
protocol CanyonMap {
    var locationService: LocationService { get }
    
    /// the map view
    var view: UIView { get }
    
    /// When the map requests to view a canyon. Supplies the canyon id
    var didRequestCanyon: PassthroughSubject<String, Never> { get }
    
    /// Canyons visible in the mapview
    var visibleCanyons: [Canyon] { get }
    
    /// Setup things like delegates, current location, etc.
    func initialize()
    
    // MARK: Render Methods

    /// Render canyon annotations on map
    func renderAnnotations(canyons: [Canyon])
    func removeAnnotations()
    
    /// Render polylines for topo lines
    func renderPolylines(canyons: [Canyon])
    /// Apply the last polyline state back to the map
    func renderPolylinesFromCache()
    func removePolylines()
    
    /// Render the waypoints within specifc canyons
    func renderWaypoints(canyon: Canyon)

    // MARK: Camera Methods
    
    /// Set the camera to the canyons
    func focusCameraOn(canyon: Canyon)
    
    /// Set the camera to current location
    func focusCameraOn(location: CLLocationCoordinate2D)
}

extension CanyonMap {
    
    public func updateInitialCamera() {
        let utahCenter = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        let center = UserDefaults.standard.lastViewCoordinate ?? utahCenter
        self.focusCameraOn(location: center)
    }
    
    public func render(canyons: [Canyon]) {
        self.removeAnnotations()
        self.removePolylines()
        
        self.renderPolylines(canyons: canyons)
        
        // render waypoints if only showing one canyon
        if canyons.count == 1 {
            self.renderWaypoints(canyon: canyons[0])
        } else {
            self.renderAnnotations(canyons: canyons)
        }
    }
    
    public func updateCamera(canyons: [Canyon]) async throws {
        // center location
        if canyons.count == 1 {
            self.focusCameraOn(canyon: canyons[0])
        } else if let lastViewed = UserDefaults.standard.lastViewCoordinate {
            self.focusCameraOn(location: lastViewed)
        } else if locationService.isLocationEnabled() {
            let location = try await self.locationService.getCurrentLocation()
            self.focusCameraOn(location: location)
        }
    }
}
