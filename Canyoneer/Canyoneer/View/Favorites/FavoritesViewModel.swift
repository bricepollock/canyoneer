//
//  FavoritesViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import RxSwift

class FavoritesViewModel: ResultsViewModel {
    enum Strings {
        static let title = "Favorites"
    }
    
    public let hasDownloadedAll: Observable<Bool>
    private let hasDownloadedAllSubject: PublishSubject<Bool>
    
    public var progress: Observable<Float> {
        return self.mapService.downloadProgress
    }
    
    private let downloadLoader = LoadingComponent()
    private let favoriteService = FavoriteService()
    private let mapService = MapService.shared
    
    init() {
        self.hasDownloadedAllSubject = PublishSubject()
        self.hasDownloadedAll = self.hasDownloadedAllSubject.asObservable()
        super.init(type: .favorites, results: [])
    }
    
    public override func refresh() {
        super.refresh()
        self.titleSubject.onNext(Strings.title)
        
        self.loadingComponent.startLoading(loadingType: .inline)
        self.favoriteService.allFavorites().subscribe { [weak self] canyons in
            defer { self?.loadingComponent.stopLoading() }
            guard let self = self else { return }
            let results = canyons.map {
                return SearchResult(name: $0.name, canyonDetails: $0)
            }
            self.initialResults = results
            self.resultsSubject.onNext(results)
            if !canyons.isEmpty {
                self.mapService.hasDownloaded(all: canyons).subscribe { [weak self] hasAll in
                    self?.hasDownloadedAllSubject.onNext(hasAll)
                } onFailure: { error in
                    Global.logger.error(error)
                    self.hasDownloadedAllSubject.onNext(false)
                }.disposed(by: self.bag)
            }
        } onFailure: { error in
            defer { self.loadingComponent.stopLoading() }
            Global.logger.error(error)
        }.disposed(by: self.bag)
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
