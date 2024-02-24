//  Created by Brice Pollock for Canyoneer on 12/17/23

import Foundation

extension UserDefaults {
    fileprivate static let lastUpdate = "last_index_update"
    fileprivate static let lastUpdateSuccess = "last_index_update_success"
    private static let storage = UserPreferencesStorage()
    
    func setLastUpdateSuccess() {
        let update = IndexUpdate(status: .success)
        Self.storage.set(key: Self.lastUpdate, value: update)
        Self.storage.set(key: Self.lastUpdateSuccess, value: update)
    }
    
    func setLastUpdateFailure(error: IndexUpdateError) {
        let update = IndexUpdate(status: .failure(error: error))
        Self.storage.set(key: Self.lastUpdate, value: update)
    }
    
    /// Result of the last update attempt from server
    /// - Returns: last update attempt information (nil if never updated from server)
    var lastUpdate: IndexUpdate? {
        guard let lastUpdate: IndexUpdate = Self.storage.get(key: Self.lastUpdate) else {
            return nil
        }
        return lastUpdate
    }
    
    /// Time of the last successful update of app from server
    /// - Returns: (nil if never updated from server)
    var lastSuccessfulUpdate: Date? {
        guard let lastUpdate: IndexUpdate = Self.storage.get(key: Self.lastUpdateSuccess) else {
            return nil
        }
        return lastUpdate.time
    }
}
