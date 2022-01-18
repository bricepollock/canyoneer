//
//  MapListViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import RxSwift

class MapListViewModel: ResultsViewModel {
    enum Strings {
        static func map(count: Int) -> String {
            return "Map (\(count) Canyons)"
        }
    }
    
    private static let maxMap = 100
    
    init(canyons: [Canyon]) {
        let results = canyons.map {
            return SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)
        }
        super.init(type: .map, results: results)
    }
    
    override func refresh() {
        super.refresh()
        self.loadingComponent.startLoading(loadingType: .inline)
        let results = Array(self.currentResults.prefix(Self.maxMap))
        self.titleSubject.onNext(Strings.map(count: results.count))
        
        self.initialResults = results
        self.resultsSubject.onNext(results)
        self.loadingComponent.stopLoading()
    }
}
