//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation

extension CanyonDataManager {    
    /// Update the cache
    internal func populate(from canyonIndexList: [CanyonIndex]) {
        self.previews = [:]
        canyonIndexList.filter {
            // Don't show closed canyons
            !$0.isClosed
        }.forEach {
            // Populate cache
            self.previews[$0.id] = $0
        }
        isLoaded = true
        Global.logger.debug("Loaded \(canyonIndexList.count) canyons into memory")
    }
}
