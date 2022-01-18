//
//  LocationService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/7/22.
//

import Foundation
import CoreLocation
import RxSwift

class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    private var locationCallback: ((CLLocation) -> Void)?
    
    public let didUpdateHeading: Observable<CLHeading>
    private let didUpdateHeadingSubject: PublishSubject<CLHeading>
    
    override init() {
        self.didUpdateHeadingSubject = PublishSubject()
        self.didUpdateHeading = self.didUpdateHeadingSubject.asObservable()
        super.init()
    }
    
    func isLocationEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func getCurrentLocation(callback: @escaping ((CLLocation) -> Void)) {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationCallback = callback
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.delegate = self
        self.locationManager.requestLocation()
        self.locationManager.startUpdatingHeading()
    }
    
    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.locationCallback?(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.didUpdateHeadingSubject.onNext(newHeading)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .denied {
            self.locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Global.logger.debug("error \(String(describing: error))");
    }
}
