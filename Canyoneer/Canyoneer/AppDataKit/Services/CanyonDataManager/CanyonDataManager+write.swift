//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation

protocol CanyonDataWriter {
    /// Gets a list of canyons that require update
    /// - Throws: Only IndexUpdateError
    func canyonsRequiringUpdate() async throws -> DataUpdate?
        
    /// Updates canyons from server and writes them to disk
    /// - Throws: Only IndexUpdateError
    func updateCanyons(from dataUpdate: DataUpdate, inBackground: Bool) async throws
}

extension CanyonDataManager: CanyonDataWriter {
    
    func canyonsRequiringUpdate() async throws -> DataUpdate? {
        // Load prior index and ensure preview cache is populated
        let _ = await canyons()
        
        // Get update
        let updatedIndex = try await canyonService.canyonIndex()
        
        // Find canyons requiring update
        let updates = updatedIndex.index.filter {
            guard let found = previews[$0.id] else {
                return true // i.e. new canyon
            }
            return found.version != $0.version
        }
        
        return DataUpdate(indexUpdate: updatedIndex, neededCanyonUpdates: updates)
    }
    
    func updateCanyons(from dataUpdate: DataUpdate, inBackground: Bool) async throws {
        // Get any new canyons and save to disk
        let canyonUpdates = try await canyonService.canyons(for: dataUpdate.neededCanyonUpdates, inBackground: inBackground)
        
        // Ensure our canyon directory exists
        try createCanyonDirectoryIfNeeded()
        
        // Write all our updated canyons to disk
        try canyonUpdates.forEach {
            try writeCanyon(response: $0, checkDir: false)
        }
        
        // Save Index File
        // We don't get here unless all canyons succeeded. This way we never complete the update unless everything succeeded and never are left in a half-success/failure state. Any partial failure means next app launch we will retry the update.
        do {
            try writeIndex(response: dataUpdate.indexUpdate)
        } catch {
            throw IndexUpdateError.indexFileWrite(error.localizedDescription)
        }
        
        // Populate cache
        populate(from: dataUpdate.indexUpdate.index)
    }
    
    internal func writeIndex(response: CanyonIndexResponse) throws {
        let indexFilePath = URL(filePath: CanyonFilePath.writableIndexPath)
        try response.data.write(to: indexFilePath)
    }
    
    /// - Parameter checkDir: Whether to check whether the directory exists before write. Helps us with performance so we don't check everytime
    internal func writeCanyon(response: CanyonResponse, checkDir: Bool) throws {
        if checkDir {
            try createCanyonDirectoryIfNeeded()
        }
        
        let canyonFilePath = URL(filePath: CanyonFilePath.writableCanyonPath(for: String(response.canyon.id)))
        try response.data.write(to: canyonFilePath)
    }
    
    private func createCanyonDirectoryIfNeeded() throws {
        let canyonDirectory = CanyonFilePath.writableCanyonDirectory
        if !fileManager.fileExists(atPath: canyonDirectory) {
            try fileManager.createDirectory(atPath: canyonDirectory, withIntermediateDirectories: true)
        }
    }
}

