//  Created by Brice Pollock for Canyoneer on 12/5/23

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class StarQualityViewModelTests: XCTestCase {
    func testStars_zero() {
        let quality: Float = 0
        let result = StarQualityViewModel.stars(quality: quality)
        XCTAssertEqual(result.count, 0)
    }
    
    func testStars_one() {
        let quality: Float = 1
        let result = StarQualityViewModel.stars(quality: quality)
        XCTAssertEqual(result.count, 1)
    }
    
    func testStars_one_one() {
        let quality: Float = 1.1
        let result = StarQualityViewModel.stars(quality: quality)
        XCTAssertEqual(result.count, 1)
    }
    
    func testStars_one_five() {
        let quality: Float = 1.5
        let result = StarQualityViewModel.stars(quality: quality)
        XCTAssertEqual(result.count, 2)
    }
    
    func testStars_one_nine() {
        let quality: Float = 1.9
        let result = StarQualityViewModel.stars(quality: quality)
        XCTAssertEqual(result.count, 2)
    }
    
    func testStars_two() {
        let quality: Float = 2
        let result = StarQualityViewModel.stars(quality: quality)
        XCTAssertEqual(result.count, 2)
    }
    
    func testStars_two_five() {
        let quality: Float = 2.5
        let result = StarQualityViewModel.stars(quality: quality)
        XCTAssertEqual(result.count, 3)
    }
    
    func testStars_three() {
        let quality: Float = 3
        let result = StarQualityViewModel.stars(quality: quality)
        XCTAssertEqual(result.count, 3)
    }
    
    func testStars_four() {
        let quality: Float = 4
        let result = StarQualityViewModel.stars(quality: quality)
        XCTAssertEqual(result.count, 4)
    }
    
    func testStars_five() {
        let quality: Float = 5
        let result = StarQualityViewModel.stars(quality: quality)
        XCTAssertEqual(result.count, 5)
    }
}
