//  Created by Brice Pollock for Canyoneer on 12/17/23

import Foundation

protocol CanyonDataReader {
    func loadIndex() async throws -> [CanyonIndex]
    
    func loadCanyonFromFile(id: String) async throws -> RopeWikiCanyon
}

extension CanyonDataManager: CanyonDataReader {
    
    func loadIndex() async throws -> [CanyonIndex] {
        do {
            return try await self.loadIndexFromFile().map {
                CanyonIndex(data: $0)
            }
        } catch {
            Global.logger.error("Serialization Error: \(String(describing: error))")
            throw RequestError.serialization
        }
    }
    
    /// Try to get the data from an updated file but fall back on bundle
    func loadIndexFromFile() async throws -> [RopeWikiCanyonIndex] {
        let indexFileURL: URL
        let updatedIndexPath = CanyonFilePath.writableIndexPath
        if fileManager.fileExists(atPath: updatedIndexPath) {
            indexFileURL = URL(filePath: updatedIndexPath)
        } else {
            indexFileURL = try CanyonFilePath.bundleIndexPath
        }
        let jsonData = try Data(contentsOf: indexFileURL, options: .mappedIfSafe)
        
        let decoder = JSONDecoder()
        return try decoder.decode([RopeWikiCanyonIndex].self, from: jsonData)
    }
    
    /// Try to get the data from an updated file but fall back on bundle
    func loadCanyonFromFile(id: String) async throws -> RopeWikiCanyon {
        let canyonFileURL: URL
        let updatedCanyonPath = CanyonFilePath.writableCanyonPath(for: id)
        if fileManager.fileExists(atPath: updatedCanyonPath) {
            canyonFileURL = URL(filePath: updatedCanyonPath)
        } else {
            canyonFileURL = try CanyonFilePath.bundleCanyonPath(for: id)
        }
        let jsonData = try Data(contentsOf: canyonFileURL, options: .mappedIfSafe)
        
        let decoder = JSONDecoder()
        return try decoder.decode(RopeWikiCanyon.self, from: jsonData)
    }
}
