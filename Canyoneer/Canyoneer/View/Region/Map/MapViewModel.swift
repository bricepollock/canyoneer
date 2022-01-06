//
//  MapViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

class MapViewModel {
    let service = RopeWikiService()
    
    func canyons() -> [Canyon] {
        return service.canyons()
    }
}
