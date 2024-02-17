//
//  CanyonViewModelTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

extension TimeZone {
    static var pst: TimeZone {
        TimeZone(abbreviation: "PST")!
    }
}

@MainActor
class WeatherViewModelTests: XCTestCase {
    func testSolarTime_lessThanHalf() {
        let sunrise = Date(timeIntervalSince1970: -Measurement(value: 12.3, unit: UnitDuration.hours).converted(to: .seconds).value)
        let sunset = Date(timeIntervalSince1970: Measurement(value: 1.1, unit: UnitDuration.hours).converted(to: .seconds).value)
        let result = WeatherViewModel.Strings.sunsetTimes(sunset: sunset, sunrise: sunrise, in: .pst)
        let expected = "Daylight: 3:42 AM - 5:06 PM (13 hours)"
        XCTAssertEqual(expected.replacingOccurrences(of: "\u{202F}", with: " "), result)
    }
    
    func testSolarTime_moreThanHalf() {
        let sunrise = Date(timeIntervalSince1970: -Measurement(value: 12.3, unit: UnitDuration.hours).converted(to: .seconds).value)
        let sunset = Date(timeIntervalSince1970: Measurement(value: 1.9, unit: UnitDuration.hours).converted(to: .seconds).value)
        let result = WeatherViewModel.Strings.sunsetTimes(sunset: sunset, sunrise: sunrise, in: .pst)
        let expected = "Daylight: 3:42 AM - 5:54 PM (14 hours)"
        XCTAssertEqual(expected.replacingOccurrences(of: "\u{202F}", with: " "), result)
    }
}
   
