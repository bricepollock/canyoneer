//
//  SearchViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import RxSwift

enum SearchType: Equatable {
    static func == (lhs: SearchType, rhs: SearchType) -> Bool {
        return lhs.typeValue == rhs.typeValue
    }
    
    case string(query: String)
    case nearMe
    case favorites
    case map(list: [SearchResult])
    
    var typeValue: Int {
        switch self {
        case .string: return 1
        case .nearMe: return 2
        case .favorites: return 3
        case .map: return 4
        }
    }
}

class SearchViewModel {
        
    enum Strings {
        static func search(query: String) -> String {
            return "Search: \(query)"
        }
        static let favorites = "Favorites"
        static func nearMe(limit: Int) -> String {
            return "Near Me (Top \(limit))"
        }
        static func map(count: Int) -> String {
            return "Map (\(count) Canyons)"
        }
    }
    private static let maxNearMe = 100
    private static let maxMap = 100
    
    public let title: Observable<String>
    private let titleSubject: PublishSubject<String>
    
    public let hasDownloadedAll: Observable<Bool>
    private let hasDownloadedAllSubject: PublishSubject<Bool>
    
    // used for what to show
    public var currentResults: [SearchResult] = []
    // used for base of the filtering
    public var initialResults: [SearchResult] = []
    // these are current results
    public let results: Observable<[SearchResult]>
    private let resultsSubject: PublishSubject<[SearchResult]>
    
    var progress: Observable<Float> {
        return self.mapService.downloadProgress
    }
    
    public let loadingComponent = LoadingComponent()
    private let downloadLoader = LoadingComponent()
    
    private let canyonService: RopeWikiServiceInterface
    private let searchService: SearchServiceInterface
    private let favoriteService = FavoriteService()
    private let mapService = MapService.shared
    private let bag = DisposeBag()
    public let type: SearchType
    
    init(
        type: SearchType,
        canyonService: RopeWikiServiceInterface = RopeWikiService(),
        searchService: SearchServiceInterface? = nil
    ) {
        self.type = type
        self.canyonService = canyonService
        self.searchService = searchService ?? SearchService(canyonService: canyonService)
        self.resultsSubject = PublishSubject()
        self.results = self.resultsSubject.asObservable()
        
        self.titleSubject = PublishSubject()
        self.title = self.titleSubject.asObservable()
        
        self.hasDownloadedAllSubject = PublishSubject()
        self.hasDownloadedAll = self.hasDownloadedAllSubject.asObservable()
        
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
                self?.initialResults = results.result
                self?.resultsSubject.onNext(results.result)
            } onFailure: { error in
                defer { self.loadingComponent.stopLoading() }
                Global.logger.error(error)
            }.disposed(by: self.bag)
        case .nearMe:
            title = Strings.nearMe(limit: Self.maxNearMe)
            self.searchService.nearMeSearch(limit: Self.maxNearMe).subscribe { [weak self] results in
                defer { self?.loadingComponent.stopLoading() }
                self?.initialResults = results.result
                self?.resultsSubject.onNext(results.result)
            } onFailure: { error in
                defer { self.loadingComponent.stopLoading() }
                Global.logger.error(error)
            }.disposed(by: self.bag)
        case .favorites:
            title = Strings.favorites
            self.favoriteService.allFavorites().subscribe { [weak self] canyons in
                defer { self?.loadingComponent.stopLoading() }
                guard let self = self else { return }
                let results = canyons.map {
                    return SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)
                }
                self.initialResults = results
                self.resultsSubject.onNext(results)
                
                self.mapService.hasDownloaded(all: canyons).subscribe { [weak self] hasAll in
                    self?.hasDownloadedAllSubject.onNext(hasAll)
                } onFailure: { error in
                    Global.logger.error(error)
                    self.hasDownloadedAllSubject.onNext(false)
                }.disposed(by: self.bag)
            } onFailure: { error in
                defer { self.loadingComponent.stopLoading() }
                Global.logger.error(error)
            }.disposed(by: self.bag)
        case .map(let list):
            let results = Array(list.prefix(Self.maxMap))
            title = Strings.map(count: results.count)
            self.initialResults = results
            self.resultsSubject.onNext(results)
            self.loadingComponent.stopLoading()
        }
        
        self.titleSubject.onNext(title)
    }
    
    func updateFromFilter(with filtered: [SearchResult]) {
        self.currentResults = filtered
        self.resultsSubject.onNext(filtered)
    }
    
    func downloadCanyonMaps() {
        self.mapService.downloadTiles(for: self.currentResults.compactMap { $0.canyonDetails }).subscribe { _ in
            defer {
                DispatchQueue.main.async {
                    self.hasDownloadedAllSubject.onNext(true)
                }
            }
            Global.logger.info("Downloaded all Canyons")
        } onFailure: { error in
            Global.logger.error(error)
        }.disposed(by: self.bag)
    }
}
