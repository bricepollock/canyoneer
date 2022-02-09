//
//  MapViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import RxSwift

class MapViewModel {
    private let locationService = LocationService()
    private let service = RopeWikiService()
    
    func canyons() -> Single<[Canyon]> {
        if locationService.isLocationEnabled() {
            return Single.create { single in
                self.locationService.getCurrentLocation { location in
                    single(.success(Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)))
                }
                return Disposables.create()
            }.flatMap { coordinate in
                return self.service.canyons(at: coordinate)
            }
        } else {
            let coordinate = Coordinate(latitude: 39.3210, longitude: -111.0937)
            return service.canyons(at: coordinate)
        }
    }
}
