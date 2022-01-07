//
//  LocationService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/7/22.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    private var locationCallback: ((CLLocation) -> Void)?
    
    override init() {
        super.init()
    }
    
    func isLocationEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func getCurrentLocation(callback: @escaping ((CLLocation) -> Void)) {
        locationManager.requestWhenInUseAuthorization()
        locationCallback = callback
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationCallback?(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Global.logger.debug("error \(String(describing: error))");
    }
}
