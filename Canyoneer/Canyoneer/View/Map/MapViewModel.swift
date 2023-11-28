//
//  MapViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

class MapViewModel {
    private let service = RopeWikiService()
    
    func canyons() async -> [Canyon] {
        return await service.canyons()
    }
}
