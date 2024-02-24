//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class IndexUpdateTests: XCTestCase {
    
    func testCodeTranslation() {
        let codes: [IndexUpdateError] = [
            .unknown("unknown"),
            .indexRequest("indexRequest"),
            .indexRequestDecoding("indexRequestDecoding"),
            .singleCanyonUpdate("singleCanyonUpdate"),
            .indexFileWrite("indexFileWrite")
        ]
                          
        codes.forEach {
            let recode = IndexUpdateError(code: $0.code, details: $0.debugDetails)
            XCTAssertEqual($0.code, recode.code, "Error (\($0.code)): \($0.debugDetails) [code] translation failure")
            XCTAssertEqual($0.debugDetails, recode.debugDetails, "Error (\($0.code)): \($0.debugDetails) [debugDetails] translation failure")
        }
    }
    
    func testIndexUpdateCodable_success() throws {
        let indexUpdate = IndexUpdate(time: Date(timeIntervalSince1970: 363), status: .success)
        
        let encoded = try JSONEncoder().encode(indexUpdate)
        let decoded = try JSONDecoder().decode(IndexUpdate.self, from: encoded)
        XCTAssertEqual(indexUpdate.time.timeIntervalSince1970, decoded.time.timeIntervalSince1970)
        XCTAssertEqual(indexUpdate.status, decoded.status)
    }
    
    func testIndexUpdateCodable_failure() throws {
        let indexUpdate = IndexUpdate(time: Date(timeIntervalSince1970: 123), status: .failure(error: .indexRequest("some request")))
        
        let encoded = try JSONEncoder().encode(indexUpdate)
        let decoded = try JSONDecoder().decode(IndexUpdate.self, from: encoded)
        XCTAssertEqual(indexUpdate.time.timeIntervalSince1970, decoded.time.timeIntervalSince1970)
        XCTAssertEqual(indexUpdate.status, decoded.status)        
    }
    
    func testIndexUpdateStatus_equivalence_success() {
        let left = IndexUpdateStatus.success
        let right = IndexUpdateStatus.success
        XCTAssertEqual(left, right)
    }
    
    func testIndexUpdateStatus_equivalence_failure() {
        let left = IndexUpdateStatus.failure(error: .unknown("left"))
        let right = IndexUpdateStatus.failure(error: .unknown("right"))
        XCTAssertEqual(left, right)
    }
    
    func testIndexUpdateStatus_equivalence_failure_mismatch() {
        let left = IndexUpdateStatus.failure(error: .indexRequest("same"))
        let right = IndexUpdateStatus.failure(error: .singleCanyonUpdate("same"))
        XCTAssertNotEqual(left, right)
    }
}
