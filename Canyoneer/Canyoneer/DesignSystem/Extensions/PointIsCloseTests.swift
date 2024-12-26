//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
import Turf
import CoreLocation
@testable import Canyoneer

class PointIsCloseTests: XCTestCase {
    func testIsClose() {
        let this = Point(CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937))
        let that = Point(CLLocationCoordinate2D(latitude: 39.3230, longitude: -111.0917))
        XCTAssertTrue(this.isClose(to: that))
        XCTAssertTrue(this.isClose(to: that))
    }
    
    func testIsClose_outsideProximity_both() {
        let this = Point(CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937))
        let that = Point(CLLocationCoordinate2D(latitude: 39.3240, longitude: -111.0907))
        XCTAssertFalse(this.isClose(to: that))
    }
}
   
