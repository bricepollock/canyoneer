//
//  LandingViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import RxSwift

struct LandingViewModel {
    private let service = RopeWikiService()
    private let searchService = SearchService()
    
    private let bag = DisposeBag()
    
    // MARK: Outputs
    
    public func canyons() -> Single<[Canyon]> {
        return service.canyons()
    }
    
    public func loadCanyonDatabase() {
        self.service.canyons().subscribe().disposed(by: self.bag)
    }
}
