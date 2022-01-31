//
//  FavoritesViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import RxSwift
import Combine

class FavoritesViewModel: ResultsViewModel {
    enum Strings {
        static let title = "Favorites"
    }
    
    public var hasDownloadedAll: AnyPublisher<Bool, Never> {
        return self.hasDownloadedAllSubject.eraseToAnyPublisher()
    }
    private let hasDownloadedAllSubject = PassthroughSubject<Bool, Never>()
    
    public var progress: AnyPublisher<Float, Never> {
        return self.mapService.downloadProgress
    }
    
    private let downloadLoader = LoadingComponent()
    private let favoriteService = FavoriteService()
    private let mapService = MapService.shared
    private var cancelables = [AnyCancellable]()
    
    init() {
        super.init(type: .favorites, results: [])
    }
    
    public override func refresh() {
        super.refresh()
        self.titleSubject.send(Strings.title)
        
        self.loadingComponent.startLoading(loadingType: .inline)
        let favoriteCancelable = self.favoriteService.allFavorites().sink { [weak self] canyons in
            defer { self?.loadingComponent.stopLoading() }
            guard let self = self else { return }
            let results = canyons.map {
                return SearchResult(name: $0.name, canyonDetails: $0)
            }
            self.initialResults = results
            self.resultsSubject.send(results)
            if !canyons.isEmpty {
                let cancelable = self.mapService.hasDownloaded(all: canyons).sink { completion in
                    switch completion {
                    case .failure(let error):
                        Global.logger.error(error as Error)
                        self.hasDownloadedAllSubject.send(false)
                    default: break;// no-op
                    }
                } receiveValue: { [weak self] hasAll in
                    self?.hasDownloadedAllSubject.send(hasAll)
                }
                self.cancelables.append(cancelable)
            }
        }
        self.cancelables.append(favoriteCancelable)
    }
    
    func downloadCanyonMaps() {
        self.mapService.downloadTiles(for: self.currentResults.compactMap { $0.canyonDetails }).subscribe { _ in
            defer {
                DispatchQueue.main.async {
                    self.hasDownloadedAllSubject.send(true)
                }
            }
            Global.logger.info("Downloaded all Canyons")
        } onFailure: { error in
            Global.logger.error(error)
        }
    }
}
