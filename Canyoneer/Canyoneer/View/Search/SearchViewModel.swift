//
//  SearchViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import RxSwift

enum SearchType {
    case string(query: String)
    case nearMe
    case favorites
}

class SearchViewModel {
    enum Strings {
        static func search(query: String) -> String {
            return "Search: \(query)"
        }
        static let favorites = "Favorites"
        static let nearMe = "Near Me"
    }
    
    public let title: Observable<String>
    private let titleSubject: PublishSubject<String>
    
    public var currentResults: [SearchResult] = []
    public let results: Observable<[SearchResult]>
    private let resultsSubject: PublishSubject<[SearchResult]>
    
    public let loadingComponent = LoadingComponent()
    
    private let canyonService: RopeWikiServiceInterface
    private let searchService = SearchService()
    private let favoriteService = FavoriteService()
    private let bag = DisposeBag()
    private let type: SearchType
    
    init(type: SearchType, canyonService: RopeWikiServiceInterface = RopeWikiService()) {
        self.type = type
        self.canyonService = canyonService
        
        self.resultsSubject = PublishSubject()
        self.results = self.resultsSubject.asObservable()
        
        self.titleSubject = PublishSubject()
        self.title = self.titleSubject.asObservable()
        
        self.results.subscribeOnNext { [weak self] results in
            self?.currentResults = results
        }.disposed(by: self.bag)
    }

    // MARK: Actions
    
    public func refresh() {
        self.loadingComponent.startLoading(loadingType: .inline)
        let title: String
        switch self.type {
        case .string(let query):
            title = Strings.search(query: query)
            self.searchService.requestSearch(for: query).subscribe { [weak self] results in
                defer { self?.loadingComponent.stopLoading() }
                self?.resultsSubject.onNext(results.result)
            } onFailure: { error in
                defer { self.loadingComponent.stopLoading() }
                Global.logger.error(error)
            }.disposed(by: self.bag)
        case .nearMe:
            title = Strings.nearMe
            self.searchService.nearMeSearch(limit: 50).subscribe { [weak self] results in
                defer { self?.loadingComponent.stopLoading() }
                self?.resultsSubject.onNext(results.result)
            } onFailure: { error in
                defer { self.loadingComponent.stopLoading() }
                Global.logger.error(error)
            }.disposed(by: self.bag)
        case .favorites:
            title = Strings.favorites
            self.canyonService.canyons().map { canyons in
                return canyons.filter { canyon in self.favoriteService.isFavorite(canyon: canyon) }
            }.subscribe { [weak self] canyons in
                defer { self?.loadingComponent.stopLoading() }
                let results = canyons.map {
                    return SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)
                }
                self?.resultsSubject.onNext(results)
            } onFailure: { error in
                defer { self.loadingComponent.stopLoading() }
                Global.logger.error(error)
            }.disposed(by: self.bag)
        }
        
        self.titleSubject.onNext(title)
    }
    
    func updateFromFilter(with filtered: [SearchResult]) {
        self.currentResults = filtered
        self.resultsSubject.onNext(filtered)
    }
}
