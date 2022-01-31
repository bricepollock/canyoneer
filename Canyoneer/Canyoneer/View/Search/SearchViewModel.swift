//
//  SearchViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import RxSwift

class SearchViewModel: ResultsViewModel {
        
    enum Strings {
        static let search = "Search"
    }
    
    private let searchService: SearchServiceInterface        
    private let bag = DisposeBag()
    
    init(
        canyonService: RopeWikiServiceInterface = RopeWikiService(),
        searchService: SearchServiceInterface? = nil
    ) {
        self.searchService = searchService ?? SearchService(canyonService: canyonService)
        super.init(type: .search, results: [])
    }

    // MARK: Actions
    
    public func search(query: String) {
        self.loadingComponent.startLoading(loadingType: .inline)
        DispatchQueue.global(qos: .userInteractive).async {
            self.searchService.requestSearch(for: query).subscribe { [weak self] results in
                DispatchQueue.main.async {
                    defer { self?.loadingComponent.stopLoading() }
                    self?.initialResults = results.result
                    self?.resultsSubject.send(results.result)
                }
            } onFailure: { error in
                DispatchQueue.main.async {
                    defer { self.loadingComponent.stopLoading() }
                    Global.logger.error(error)
                }
            }.disposed(by: self.bag)

        }
    }
    
    public func clearResults() {
        self.resultsSubject.send([])
    }
}
