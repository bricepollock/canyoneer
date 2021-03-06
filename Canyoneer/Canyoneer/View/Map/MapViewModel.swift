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
    
    func canyons() -> Single<[Canyon]> {
        return service.canyons()
    }
}
