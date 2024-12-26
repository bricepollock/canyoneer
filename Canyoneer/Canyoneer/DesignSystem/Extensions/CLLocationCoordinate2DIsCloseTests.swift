//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
import Turf
import CoreLocation
@testable import Canyoneer

class CLLocationCoordinate2DIsCloseTests: XCTestCase {
    func testIsClose_equal() {
        let this = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        let that = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        XCTAssertTrue(this.isClose(to: that))
    }
    
    func testIsClose_withinProximity() {
        let this = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        let that = CLLocationCoordinate2D(latitude: 39.3230, longitude: -111.0917)
        XCTAssertTrue(this.isClose(to: that))
    }
    
    func testIsClose_outsideProximity_long() {
        let this = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        let that = CLLocationCoordinate2D(latitude: 39.3230, longitude: -111.0907)
        XCTAssertFalse(this.isClose(to: that))
    }
    
    func testIsClose_outsideProximity_lat() {
        let this = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        let that = CLLocationCoordinate2D(latitude: 39.3240, longitude: -111.0917)
        XCTAssertFalse(this.isClose(to: that))
    }
    
    func testIsClose_outsideProximity_both() {
        let this = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        let that = CLLocationCoordinate2D(latitude: 39.3240, longitude: -111.0907)
        XCTAssertFalse(this.isClose(to: that))
    }
    
    func testIsClose_overrideProximity() {
        let this = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        let that = CLLocationCoordinate2D(latitude: 39.3240, longitude: -111.0907)
        XCTAssertTrue(this.isClose(to: that, proximity: 3))
    }
}
   
