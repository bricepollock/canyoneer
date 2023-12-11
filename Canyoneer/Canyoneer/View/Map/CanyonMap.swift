//
//  MapView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import SwiftUI
import CoreLocation
import Combine

protocol CanyonMap {
    var view: CanyonMapViewType { get }
    
    var locationService: LocationService { get }
    
    /// When the map requests to view a canyon. Supplies the canyon id
    var didRequestCanyon: PassthroughSubject<String, Never> { get }
    
    /// Canyons visible in the mapview
    var visibleCanyons: [Canyon] { get }
    var currentCanyons: [Canyon] { get }
    
    /// Setup things like delegates, current location, etc.
    func initialize()
    
    // MARK: Render Methods

    /// Add canyon annotations on map
    func addAnnotations(for canyons: [Canyon])
    /// Remove canyon annotations on map
    func removeAnnotations(for canyonMap: [String: Canyon])
    /// Remove all canyon annotations on map
    func removeAnnotations()
    func deselectCanyons()
    
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
    
    /// Complexity: 4*n, could maybe do an optimization of patching only on screen and otherwise group update
    public func render(canyons updated: [Canyon]) {
        Global.logger.debug("Rendering canyons: \(updated.count)")
        
        var updatedMap = [String: Canyon]()
        updated.forEach { updatedMap[$0.id] = $0}
        
        let current = currentCanyons
        var currentMap = [String: Canyon]()
        current.forEach { currentMap[$0.id] = $0}
        
        
        var removed = [String: Canyon]()
        var added = [Canyon]()
        updated
            .filter { currentMap[$0.id] == nil }
            .forEach {
                added.append($0)
            }
        current
            .filter { updatedMap[$0.id] == nil }
            .forEach {
                removed[$0.id] = $0
            }
                
        self.removePolylines()
        self.renderPolylines(canyons: updated)
        
        // render waypoints if only showing one canyon
        if updated.count == 1 {
            self.renderWaypoints(canyon: updated[0])
        } else {
            self.removeAnnotations(for: removed)
            self.addAnnotations(for: added)
        }
    }
    
    public func updateCamera(canyons: [Canyon]) async throws {
        // center location
        if canyons.count == 1 {
            self.focusCameraOn(canyon: canyons[0])
        } else if canyons.isEmpty == false && canyons.count < 100 {
            self.focusCameraOn(location: canyons[0].coordinate.asCLObject)
        } else if let lastViewed = UserDefaults.standard.lastViewCoordinate {
            self.focusCameraOn(location: lastViewed)
        } else if locationService.isLocationEnabled() {
            let location = try await self.locationService.getCurrentLocation()
            self.focusCameraOn(location: location)
        }
    }
}
