//
//  CanyonViewControllerTests.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import XCTest
@testable import Canyoneer

class CanyonViewControllerTests: XCTestCase {
   
    func testName() {
        let name = "Moonflower Canyon"
        let expected = "Canyon: Moonflower Canyon"
        let result = CanyonViewController.Strings.name(with: name)
        XCTAssertEqual(expected, result)
    }
    
    func testMessage() {
        let canyon = Canyon.dummy()
        let expected = "I found 'Moonflower Canyon 3A II 2r ↧220ft' on the 'Canyoneer' app. Check out the canyon on Ropewiki: http://ropewiki.com/Moonflower_Canyon"
        let result = CanyonViewController.Strings.message(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testMessage_noUrl() {
        var canyon = Canyon.dummy()
        canyon.ropeWikiURL = nil
        let expected = "I found 'Moonflower Canyon 3A II 2r ↧220ft' on the 'Canyoneer' app."
        let result = CanyonViewController.Strings.message(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testBody() {
        let canyon = Canyon.dummy()
        let expected = "I found 'Moonflower Canyon 3A II 2r ↧220ft' on the 'Canyoneer' app. Check out the canyon on Ropewiki: http://ropewiki.com/Moonflower_Canyon"
        let result = CanyonViewController.Strings.body(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testBody_noUrl() {
        var canyon = Canyon.dummy()
        canyon.ropeWikiURL = nil
        let expected = "I found 'Moonflower Canyon 3A II 2r ↧220ft' on the 'Canyoneer' app."
        let result = CanyonViewController.Strings.body(for: canyon)
        XCTAssertEqual(expected, result)
    }
    
    func testSubject() {
        let name = "Moonflower Canyon"
        let expected = "Check out this cool canyon: Moonflower Canyon"
        let result = CanyonViewController.Strings.subject(name: name)
        XCTAssertEqual(expected, result)
    }
    
}
