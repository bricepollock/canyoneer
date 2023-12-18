//  Created by Brice Pollock for Canyoneer on 12/17/23

import Foundation

struct CanyonFilePath {
    static func indexPath() throws -> URL {
        let bundle = Bundle(for: CanyonAPIService.self)
        guard let indexFilePath = bundle.path(forResource: "index", ofType: "json") else {
            Global.logger.error("Failed to find index file!")
            throw RequestError.serialization
        }
        return URL(fileURLWithPath: indexFilePath)
    }
    
    static func canyonPath(for id: String) throws -> URL {
        let indexFileURL = try indexPath()
        let baseDirectory = indexFileURL.deletingLastPathComponent()
        let canyonDirectory = baseDirectory.appending(component: "CanyonDetails")
        return canyonDirectory.appending(component: "\(id).json")
    }
}
