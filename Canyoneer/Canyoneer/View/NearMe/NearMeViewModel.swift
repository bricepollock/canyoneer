//
//  NearMeViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation

@MainActor
class NearMeViewModel: ResultsViewModel {
    
    enum Strings {
        static func nearMe(limit: Int) -> String {
            return "Near Me (Top \(limit))"
        }
    }
    private static let maxNearMe = 100
    
    private let searchService: SearchServiceInterface
    
    init(searchService: SearchServiceInterface = SearchService()) {
        self.searchService = searchService
        super.init(type: .nearMe, results: [])
    }
    
    override func refresh() async {
        self.title = Strings.nearMe(limit: Self.maxNearMe)
        
        do {
            let results = try await self.searchService.nearMeSearch(limit: Self.maxNearMe)
            self.initialResults = results.result
            self.currentResults = results.result
        } catch {
            Global.logger.error(error)
        }
        self.loadingComponent.stopLoading()
    }
}
