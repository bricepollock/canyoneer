//  Created by Brice Pollock for Canyoneer on 12/17/23

import Foundation

extension UserDefaults {
    
    fileprivate static let lastIndexUpdate = "last_index_update_time"
    private static let storage = UserPreferencesStorage()
    
    func setLastIndexUpdate() {
        Self.storage.set(key: Self.lastIndexUpdate, value: Date().timeIntervalSince1970)
    }
    
    var lastIndexUpdate: Date? {
        guard let time: Double = Self.storage.get(key: Self.lastIndexUpdate) else {
            return nil
        }
        return Date(timeIntervalSince1970: time)
    }
}
