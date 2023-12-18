//  Created by Brice Pollock for Canyoneer on 12/17/23

import Foundation

/// Represents updated data transaction
struct DataUpdate {
    let index: [CanyonIndex]
    let requiredUpdates: [CanyonIndex]
    
    let indexData: Data
}

// FIXME: Think about failure cases and how we report it for background task (notification?)
// FIXME: Think about user-on-demand sync and watch UI
extension CanyonAPIService {
    /// How long between updates from server
    private static let updateInterval: Measurement<UnitDuration> = Measurement(value: 7 * 24, unit: .hours)
    
    /// Gets a list of canyons that require update
    func canyonsRequiringUpdate() async throws -> DataUpdate? {
        // Load prior index
        let canyonsFromFile = await canyons()
        
        // Check if need update
        if !canyonsFromFile.isEmpty, let lastUpdate = storage.lastIndexUpdate {
            let nextUpdate = lastUpdate.addingTimeInterval(Self.updateInterval.converted(to: .seconds).value)
            guard Date() > nextUpdate else {
                return nil
            }
        }
        
        // Get update
        let decoder = JSONDecoder()
        let request = URLRequest(url: CanyonAPIURL.index)
        let (data, _) = try await URLSession.shared.data(for: request)
        let newIndex = try decoder.decode([RopeWikiCanyonIndex].self, from: data).map {
            CanyonIndex(data: $0)
        }
        
        // Find canyons requiring update
        let updates = newIndex.filter {
            guard let found = previews[$0.id] else {
                return true // i.e. new canyon
            }
            return found.version != $0.version
        }
        
        return DataUpdate(index: newIndex, requiredUpdates: updates, indexData: data)
    }
    
    /// Updates canyons from server and writes them to disk
    func updateCanyons(from dataUpdate: DataUpdate) async throws {
        // Get any new canyons and save to disk
        try await withThrowingTaskGroup(of: Void.self) { group in
            dataUpdate.requiredUpdates.forEach { canyon in
                _ = group.addTaskUnlessCancelled { [weak self] in
                    guard let self else { return }
                    do {
                        try await updateCanyon(with: canyon.id)
                        Global.logger.debug("Download update for canyon \(canyon.id)")
                    } catch {
                        Global.logger.error("Failed to download canyon for \(canyon.id): \(error)")
                        throw error
                    }
                }
            }
            
            for try await _ in group {
                Global.logger.debug("Download complete")
            }
        }
        
        // Save Index File
        // We don't get here unless all canyons succeeded. This way we never complete the update unless everything succeeded and never are left in a half-success/failure state. Any partial failure means next app launch we will retry the update.
        let indexFilePath = try CanyonFilePath.indexPath()
        try dataUpdate.indexData.write(to: indexFilePath)
        
        // Populate cache
        populate(from: dataUpdate.index)
    }
    
    private func updateCanyon(with id: String) async throws {
        let decoder = JSONDecoder()
        let request = URLRequest(url: CanyonAPIURL.canyon(with: id))
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Ensure it unpacks
        let _ = try decoder.decode(RopeWikiCanyon.self, from: data)
        
        // Overwrite
        let canyonFilePath = try CanyonFilePath.canyonPath(for: id)
        try data.write(to: canyonFilePath)
    }
}
