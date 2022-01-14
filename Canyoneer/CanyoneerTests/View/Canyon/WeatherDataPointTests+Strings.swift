//
//  WeatherDataPointTests+Strings.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/14/22.
//

import Foundation
import XCTest
@testable import Canyoneer

class WeatherDataPointStringsTests: XCTestCase {
    func testSolarTime_lessThanHalf() {
        let point = WeatherDataPoint.dummy()
        point.temperatureMax = 92.345
        point.temperatureMin = 23.755
        point.precipProbability = 0.44556
        point.time = Date(timeIntervalSince1970: 0)
        
        guard let result = point.dayDetails else {
            XCTFail(); return
        }
        XCTAssertEqual(result.dayOfWeek, "Wednesday")
        XCTAssertEqual(result.temp, "23 - 92 °F")
        XCTAssertEqual(result.precip, "44% Moisture")
    }
}
    
