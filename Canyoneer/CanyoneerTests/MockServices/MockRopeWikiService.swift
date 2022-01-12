//
//  MockRopeWikiService.swift
//  CanyoneerTests
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import RxSwift
@testable import Canyoneer

class MockRopeWikiService: RopeWikiServiceInterface {
    public var mockCanyons = [Canyon]()
    func canyons() -> Single<[Canyon]> {
        return Single.just(mockCanyons)
    }
    
    public var mockCanyon: Canyon? = nil
    func canyon(for id: String) -> Single<Canyon?> {
        return Single.just(mockCanyon)
    }
}
