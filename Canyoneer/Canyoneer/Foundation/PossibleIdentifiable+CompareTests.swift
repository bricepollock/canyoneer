//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
import MapboxMaps
@testable import Canyoneer

struct MockPossibleIdentifable: PossibleIdentifable {
    var lookupID: String?
    
    init() {
        self.init(id: UUID().uuidString)
    }
    
    private init(id: String?) {
        self.lookupID = id
    }
    
    static var empty: PossibleIdentifable {
        MockPossibleIdentifable(id: nil)
    }
}

@MainActor
class PossibleIdentifable_CompareTests: XCTestCase {
    func testCompare_empty_empty() {
        let this: [MockPossibleIdentifable] = []
        let that: [MockPossibleIdentifable] = []
        let lookup = this.compare(to: that)
        
        XCTAssertEqual(lookup.added.keys.count, 0)
        XCTAssertEqual(lookup.removed.keys.count, 0)
        XCTAssertEqual(lookup.matched.keys.count, 0)
        XCTAssertEqual(lookup.merged.keys.count, 0)
        XCTAssertEqual(lookup.updateFromNew.count, 0)
    }
    
    func testCompare_empty_notEmpty() {
        let this: [MockPossibleIdentifable] = []
        let that: [MockPossibleIdentifable] = [
            MockPossibleIdentifable(),
            MockPossibleIdentifable(),
            MockPossibleIdentifable()
        ]
        let lookup = this.compare(to: that)
        
        XCTAssertEqual(lookup.added.keys.count, 0)
        XCTAssertEqual(lookup.removed.keys.count, that.count)
        XCTAssertEqual(lookup.matched.keys.count, 0)
        XCTAssertEqual(lookup.merged.keys.count, that.count)
        XCTAssertEqual(lookup.updateFromNew.count, 0)
    }
    
    func testCompare_notEmpty_empty() {
        let this: [MockPossibleIdentifable] = [
            MockPossibleIdentifable(),
            MockPossibleIdentifable(),
            MockPossibleIdentifable()
        ]
        let that: [MockPossibleIdentifable] = []
        let lookup = this.compare(to: that)
        
        XCTAssertEqual(lookup.added.keys.count, this.count)
        XCTAssertEqual(lookup.removed.keys.count, 0)
        XCTAssertEqual(lookup.matched.keys.count, 0)
        XCTAssertEqual(lookup.merged.keys.count, this.count)
        XCTAssertEqual(lookup.updateFromNew.count, this.count)
    }
    
    func testCompare_notEmpty_notEmpty() {
        let shared: [MockPossibleIdentifable] = [
            MockPossibleIdentifable(),
            MockPossibleIdentifable()
        ]
        let this: [MockPossibleIdentifable] = shared + [
            MockPossibleIdentifable(),
        ]
        let that: [MockPossibleIdentifable] = [
            MockPossibleIdentifable(),
            MockPossibleIdentifable(),
            MockPossibleIdentifable()
        ] + shared
        let lookup = this.compare(to: that)
        
        XCTAssertEqual(lookup.added.keys.count, 1)
        XCTAssertEqual(lookup.removed.keys.count, 3)
        XCTAssertEqual(lookup.matched.keys.count, shared.count)
        XCTAssertEqual(lookup.merged.keys.count, 6)
        XCTAssertEqual(lookup.updateFromNew.count, this.count)
    }
    
    func testCompare_match() {
        let shared: [MockPossibleIdentifable] = [
            MockPossibleIdentifable(),
            MockPossibleIdentifable()
        ]
        let this: [MockPossibleIdentifable] = shared
        let that: [MockPossibleIdentifable] = shared
        let lookup = this.compare(to: that)
        
        XCTAssertEqual(lookup.added.keys.count, 0)
        XCTAssertEqual(lookup.removed.keys.count, 0)
        XCTAssertEqual(lookup.matched.keys.count, shared.count)
        XCTAssertEqual(lookup.merged.keys.count, shared.count)
        XCTAssertEqual(lookup.updateFromNew.count, shared.count)
    }
    
    func testCompare_canyonPins() {
        let this: [CanyonIndex] = [
            CanyonIndex(),
            CanyonIndex(),
            CanyonIndex()
        ]
        let that: [PointAnnotation] = [
            PointAnnotation.makeCanyonAnnotation(for: this[1]),
            PointAnnotation.makeCanyonAnnotation(for: CanyonIndex())
        ]
        let lookup = this.compare(to: that)
        
        XCTAssertEqual(lookup.added.keys.count, 2)
        XCTAssertEqual(lookup.removed.keys.count, 1)
        XCTAssertEqual(lookup.matched.keys.count, 1)
        XCTAssertEqual(lookup.merged.keys.count, 4)
        XCTAssertEqual(lookup.updateFromNew.count, this.count)
    }
}
