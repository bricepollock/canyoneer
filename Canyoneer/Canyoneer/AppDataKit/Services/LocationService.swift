//
//  LocationService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/7/22.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    
    @Published var heading: CLHeading?
    
    private var authorizationContinuation: CheckedContinuation<Bool, Never>?
    
    /// Need to be careful with resource contention of multiple callers creating parallel continuations
    @MainActor
    private var currentLocationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    private let locationManager = CLLocationManager()
    
    func isLocationEnabled() -> Bool {
        return locationManager.authorizationStatus != .denied
    }
    
    /// MainActor to prevent parallel continuations
    @MainActor
    func getCurrentLocation() async throws -> CLLocationCoordinate2D {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.delegate = self
        
        let canUseLocation: Bool
        let authStatus = self.locationManager.authorizationStatus
        if authStatus == .notDetermined {
            canUseLocation = await withCheckedContinuation { continuation in
                authorizationContinuation = continuation
                self.locationManager.requestWhenInUseAuthorization()
            }
        } else {
            canUseLocation = authStatus != .denied
        }
        
        guard canUseLocation else {
            throw GeneralError.permissionsDenied
        }
        authorizationContinuation = nil
                
        self.locationManager.startUpdatingHeading()
                
        // Clear out any pending task
        currentLocationContinuation?.resume(throwing: CancellationError())
        currentLocationContinuation = nil
        
        // Launch another
        return try await withCheckedThrowingContinuation { continuation in
            currentLocationContinuation = continuation
            self.locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .denied {
            authorizationContinuation?.resume(returning: true)
        } else {
            authorizationContinuation?.resume(returning: false)
        }
    }
    
    // MARK: Location Updating
    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task(priority: .high) {
            await self.updateLocation(to: .success(locations.last))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task(priority: .high) {
            await self.updateLocation(to: .failure(error))
        }
    }
    
    @MainActor
    private func updateLocation(to location: Result<CLLocation?, Error>) {
        switch location {
        case .success(let location):
            if let location {
                currentLocationContinuation?.resume(returning: location.coordinate)
            } else {
                currentLocationContinuation?.resume(throwing: GeneralError.notFound)
            }
        case .failure(let error):
            Global.logger.debug("error getting location \(String(describing: error))");
            currentLocationContinuation?.resume(throwing: GeneralError.unknownFailure)
        }
        currentLocationContinuation = nil
    }
}
