//
//  RopeWikiService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

struct RopeWikiService {
    func canyons() -> [Canyon] {
        return self.canyons(with: self.regions())
    }
    
    func regions() -> [Region] {
        return [
            Self.california,
            Self.utah
        ]
    }
    
    private func canyons(with regions: [Region]) -> [Canyon] {
        return regions.flatMap { region in
            return self.canyons(for: region)
        }
    }
    
    private func canyons(for region: Region) -> [Canyon] {
        guard region.canyons.isEmpty else {
            return region.canyons
        }
        return self.canyons(with: region.children)
    }
}
