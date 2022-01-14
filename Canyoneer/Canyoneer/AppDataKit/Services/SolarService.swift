//
//  SolarService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/14/22.
//

import Foundation
import Solar
import RxSwift
import CoreLocation

struct SunTime {
    let sunrise: Date
    let sunset: Date
}

class SolarService {
    func sunTimes(for coordinate: CLLocationCoordinate2D) -> Single<SunTime> {
        guard let result = Solar(for: Date(), coordinate: coordinate) else {
            return Single.error(RequestError.noResponse)
        }
        guard let sunrise = result.sunrise, let sunset = result.sunset else {
            return Single.error(RequestError.noResponse)
        }
        return Single.just(SunTime(sunrise: sunrise, sunset: sunset))
    }
}
