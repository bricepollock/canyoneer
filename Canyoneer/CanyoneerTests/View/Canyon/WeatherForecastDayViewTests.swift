//
//  WeatherForecastDayViewTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import XCTest
@testable import Canyoneer

class WeatherForecastDayViewTests: XCTestCase {
   
    func testTemp() {
        let max: Double = 100
        let min: Double = 75.123
        let expected = "100 - 75 °F"
        let result = WeatherForecastDayView.Strings.temp(max: max, min: min)
        XCTAssertEqual(expected, result)
    }
    
    func testPrecip() {
        let chance = 0.25884
        let expected = "25% Moisture"
        let result = WeatherForecastDayView.Strings.precip(chance: chance)
        XCTAssertEqual(expected, result)
    }
}
