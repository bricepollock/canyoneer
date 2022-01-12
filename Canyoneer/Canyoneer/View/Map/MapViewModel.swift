//
//  MapViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import RxSwift

class MapViewModel {
    private let service = RopeWikiService()
    private var cache: [Canyon]?
    
    func canyons() -> Single<[Canyon]> {
        guard let cache = self.cache else {
            return service.canyons().do { canyons in
                self.cache = canyons
            }
        }
        return Single.just(cache)
    }
}
