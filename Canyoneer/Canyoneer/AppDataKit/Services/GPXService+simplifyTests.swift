//
//  GPXService+simplifyTests.swift
//  Canyoneer
//
//  Created by Brice Pollock on 11/19/23.
//

import Foundation
import XCTest
@testable import Canyoneer

class GPXServiceSimplifyTests: XCTestCase {
    func testSimplify() {
        // Taken from Uranus canyon with a couple additions to be removed
        let coordinates = [
            Coordinate(
                latitude: 36.3887494337,
                longitude: -116.6066334955
            ),
            Coordinate(
                latitude: 36.38875,
                longitude: -116.60663
            ),
            Coordinate(
                latitude: 36.3888233621,
                longitude: -116.606581863
            ),
            Coordinate(
                latitude: 36.3889055047,
                longitude: -116.6065509338
            ),
            Coordinate(
                latitude: 36.3889876474,
                longitude: -116.6065405402
            ),
            Coordinate(
                latitude: 36.3890615758,
                longitude: -116.6064682882
            ),
            Coordinate(
                latitude: 36.3891355041,
                longitude: -116.6063960362
            ),
            Coordinate(
                latitude: 36.3892012183,
                longitude: -116.6063134745
            ),
            Coordinate(
                latitude: 36.3892587181,
                longitude: -116.6062309127
            ),
            Coordinate(
                latitude: 36.3892751466,
                longitude: -116.6061070282
            ),
            Coordinate(
                latitude: 36.3892340753,
                longitude: -116.6060141567
            ),
            Coordinate(
                latitude: 36.3891847897,
                longitude: -116.605931595
            ),
            Coordinate(
                latitude: 36.3891437184,
                longitude: -116.6058387235
            ),
            Coordinate(
                latitude: 36.3891272899,
                longitude: -116.6057354584
            ),
            Coordinate(
                latitude: 36.3891190756,
                longitude: -116.6056322772
            ),
            Coordinate(
                latitude: 36.3891026471,
                longitude: -116.6055290122
            ),
            Coordinate(
                latitude: 36.3890780043,
                longitude: -116.6054258309
            ),
            Coordinate(
                latitude: 36.3890615758,
                longitude: -116.6053225659
            ),
            Coordinate(
                latitude: 36.3890615758,
                longitude: -116.6052090749
            ),
            Coordinate(
                latitude: 36.3890615758,
                longitude: -116.6050851904
            ),
            Coordinate(
                latitude: 36.3890615758,
                longitude: -116.6049716156
            ),
            Coordinate(
                latitude: 36.3890451472,
                longitude: -116.6048581246
            ),
            Coordinate(
                latitude: 36.3890205044,
                longitude: -116.6047548596
            ),
            Coordinate(
                latitude: 36.3889876474,
                longitude: -116.6046413686
            ),
            Coordinate(
                latitude: 36.388946576,
                longitude: -116.6045381036
            ),
            Coordinate(
                latitude: 36.388913719,
                longitude: -116.6044349223
            ),
            Coordinate(
                latitude: 36.3888808619,
                longitude: -116.6043316573
            ),
            Coordinate(
                latitude: 36.38888,
                longitude: -116.60427
            ),
            Coordinate(
                latitude: 36.38888,
                longitude: -116.60427
            ),
            Coordinate(
                latitude: 36.3888562191,
                longitude: -116.6042284761
            ),
            Coordinate(
                latitude: 36.3888233621,
                longitude: -116.6041149013
            ),
            Coordinate(
                latitude: 36.388790505,
                longitude: -116.60401172
            ),
            Coordinate(
                latitude: 36.3887658622,
                longitude: -116.603908455
            ),
            Coordinate(
                latitude: 36.3887412194,
                longitude: -116.6038052738
            ),
            Coordinate(
                latitude: 36.3886755053,
                longitude: -116.603722712
            ),
            Coordinate(
                latitude: 36.3886426482,
                longitude: -116.603619447
            )
            
        ]
        
        var prev = coordinates[0]
        coordinates.dropFirst().forEach {
            print(prev.distance(to: $0).value)
            prev = $0
        }
        
        let result = GPXService.simplify(coordinates: coordinates)
        XCTAssertEqual(result.count, coordinates.count-2)
    }
}
   
