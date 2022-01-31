//
//  NearMeViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import RxSwift

class NearMeViewModel: ResultsViewModel {
    
    enum Strings {
        static func nearMe(limit: Int) -> String {
            return "Near Me (Top \(limit))"
        }
    }
    private static let maxNearMe = 100
    
    private let searchService: SearchServiceInterface
    private let bag = DisposeBag()
    
    init(searchService: SearchServiceInterface = SearchService()) {
        self.searchService = searchService
        super.init(type: .nearMe, results: [])
    }
    
    override func refresh() {
        
        self.titleSubject.send(Strings.nearMe(limit: Self.maxNearMe))
        self.searchService.nearMeSearch(limit: Self.maxNearMe).subscribe { [weak self] results in
            defer { self?.loadingComponent.stopLoading() }
            self?.initialResults = results.result
            self?.resultsSubject.send(results.result)
        } onFailure: { error in
            defer { self.loadingComponent.stopLoading() }
            Global.logger.error(error)
        }.disposed(by: self.bag)
    }
}
