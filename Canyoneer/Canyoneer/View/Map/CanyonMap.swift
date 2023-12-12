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
    var visibleCanyons: [CanyonIndex] { get }
    var currentCanyons: [CanyonIndex] { get }
    
    /// Setup things like delegates, current location, etc.
    func initialize()
    
    // MARK: Annotation Render Methods

    /// Add canyon annotations on map
    func addAnnotations(for canyons: [CanyonIndex])
    /// Remove canyon annotations on map
    func removeAnnotations(for canyonMap: [String: CanyonIndex])
    /// Remove all canyon annotations on map
    func removeAnnotations()
    func deselectCanyons()
    
    // MARK: Geometry Render Methods
    
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
    
    // MARK: Render details of a group of canyons
    
    /// Complexity: 4*n, could maybe do an optimization of patching only on screen and otherwise group update
    public func render(canyons updated: [CanyonIndex]) {
        Global.logger.debug("Rendering canyons: \(updated.count)")
        
        var updatedMap = [String: CanyonIndex]()
        updated.forEach { updatedMap[$0.id] = $0}
        
        let current = currentCanyons
        var currentMap = [String: CanyonIndex]()
        current.forEach { currentMap[$0.id] = $0}
        
        
        var removed = [String: CanyonIndex]()
        var added = [CanyonIndex]()
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
                
        // FIXME: We dropped support of TOPO lines on map to migrate to index file, when we address [ISSUE-6] we can use the mapbox tiles and avoid loading all KLM into memory which should allow us to put topo lines back on the map
//        self.removePolylines()
//        self.renderPolylines(canyons: updated)
        
        self.removeAnnotations(for: removed)
        self.addAnnotations(for: added)
    }
    
    public func updateCamera(canyons: [CanyonIndex]) async throws {
        // center location
        if canyons.isEmpty == false && canyons.count < 100 {
            self.focusCameraOn(location: canyons[0].coordinate.asCLObject)
        } else if let lastViewed = UserDefaults.standard.lastViewCoordinate {
            self.focusCameraOn(location: lastViewed)
        } else if locationService.isLocationEnabled() {
            let location = try await self.locationService.getCurrentLocation()
            self.focusCameraOn(location: location)
        }
    }
    
    // MARK: Render details of a single canyon
    
    public func render(canyon: Canyon) {
        self.removePolylines()
        self.renderPolylines(canyons: [canyon])
        self.renderWaypoints(canyon: canyon)
    }
    
    public func updateCamera(to canyon: Canyon) async throws {
        self.focusCameraOn(canyon: canyon)
    }
}
