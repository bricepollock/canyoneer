//
//  MockRopeWikiService.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
@testable import Canyoneer

class MockRopeWikiService: RopeWikiServiceInterface {
    public var mockCanyons = [Canyon]()
    func canyons() async -> [Canyon] {
        return mockCanyons
    }
    
    public var mockCanyon: Canyon? = nil
    func canyon(for id: String) async throws -> Canyon {
        guard let mockCanyon else {
            throw GeneralError.notFound
        }
        return mockCanyon
    }
}
