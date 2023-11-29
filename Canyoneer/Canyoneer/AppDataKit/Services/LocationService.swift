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
    private var currentLocationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    private let locationManager = CLLocationManager()
    
    func isLocationEnabled() -> Bool {
        return locationManager.authorizationStatus != .denied
    }
    
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
        
        defer { currentLocationContinuation = nil }
        return try await withCheckedThrowingContinuation { continuation in
            currentLocationContinuation = continuation
            self.locationManager.requestLocation()
        }
        
    }
    
    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocationContinuation?.resume(returning: location.coordinate)
        } else {
            currentLocationContinuation?.resume(throwing: GeneralError.notFound)
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Global.logger.debug("error \(String(describing: error))");
        currentLocationContinuation?.resume(throwing: GeneralError.unknownFailure)
    }
}
