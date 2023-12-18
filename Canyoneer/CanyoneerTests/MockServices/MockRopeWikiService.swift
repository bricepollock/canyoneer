//
//  MockCanyonAPIService.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
@testable import Canyoneer

class MockCanyonAPIService: CanyonAPIServing {
    public var mockCanyons = [CanyonIndex]()
    func canyons() async -> [CanyonIndex] {
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
