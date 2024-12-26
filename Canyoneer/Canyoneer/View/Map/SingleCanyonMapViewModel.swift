//  Created by Brice Pollock for Canyoneer on 3/8/24

import Foundation
import Combine
import SwiftUI
import CoreLocation

@MainActor
class SingleCanyonMapViewModel: ObservableObject {
    public let mapViewModel: MapboxMapViewModel
    private let canyon: Canyon
    private let locationService: LocationService
    
    /// Whether the map is centered at current location
    @Published var isAtCurrentLocation: Bool = false
    /// The user location the last time the 'go to current location' button was tapped
    private var lastUserLocation: CLLocationCoordinate2D?
        
    init(
        canyon: Canyon,
        locationService: LocationService = LocationService()
    ) {
        self.canyon = canyon
        self.mapViewModel = MapboxMapViewModel(locationService: locationService)
        self.locationService = locationService
        
        // Initialize Current Location
        Task(priority: .high) {
            self.lastUserLocation = try? await locationService.getCurrentLocation()
        }
    }
    
    public func onAppear() {
        self.mapViewModel.initialize()
        self.mapViewModel.focusCameraOn(canyon: canyon, animated: false)
        self.mapViewModel.updatePolylines(to: [canyon])
        self.mapViewModel.renderWaypoints(canyon: canyon)
        
        // Observe the map state change to know whether centered on current location
        mapViewModel.$visibleMap
            .map { [weak self] _ in
                guard let self, let lastUserLocation else { return false }
                return mapViewModel.center.isClose(to: lastUserLocation)
            }
            .removeDuplicates()
            .assign(to: &$isAtCurrentLocation)
    }
    
    public func goToCurrentLocation() async {
        guard let currentLocation = try? await locationService.getCurrentLocation() else {
            return
        }
        self.lastUserLocation = currentLocation
        self.mapViewModel.focusCameraOn(location: currentLocation, animated: true)
    }
}
