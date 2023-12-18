//  Created by Brice Pollock for Canyoneer on 12/17/23

import Foundation

extension CanyonAPIService {
    
    internal func loadIndex() throws -> [CanyonIndex] {
        do {
            return try self.loadIndexFromFile().map {
                CanyonIndex(data: $0)
            }
        } catch {
            Global.logger.error("Serialization Error: \(String(describing: error))")
            throw RequestError.serialization
        }
    }
    
    internal func loadIndexFromFile() throws -> [RopeWikiCanyonIndex] {
        let indexFilePath = try CanyonFilePath.indexPath()
        let jsonData = try Data(contentsOf: indexFilePath, options: .mappedIfSafe)
        
        let decoder = JSONDecoder()
        return try decoder.decode([RopeWikiCanyonIndex].self, from: jsonData)
    }
    
    internal func loadCanyonFromFile(id: String) throws -> RopeWikiCanyon {
        let canyonFilePath = try CanyonFilePath.canyonPath(for: id)
        let jsonData = try Data(contentsOf: canyonFilePath, options: .mappedIfSafe)
        
        let decoder = JSONDecoder()
        return try decoder.decode(RopeWikiCanyon.self, from: jsonData)
    }
}
