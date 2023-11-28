//
//  SolarService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/14/22.
//

import Foundation
import Solar
import CoreLocation

struct SunTime {
    let sunrise: Date
    let sunset: Date
}

class SolarService {
    func sunTimes(for coordinate: CLLocationCoordinate2D) throws -> SunTime {
        guard let result = Solar(for: Date(), coordinate: coordinate) else {
            throw RequestError.noResponse
        }
        guard let sunrise = result.sunrise, let sunset = result.sunset else {
            throw RequestError.noResponse
        }
        return SunTime(sunrise: sunrise, sunset: sunset)
    }
}
