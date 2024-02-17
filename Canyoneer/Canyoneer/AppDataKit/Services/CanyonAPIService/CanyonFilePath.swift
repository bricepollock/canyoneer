//  Created by Brice Pollock for Canyoneer on 12/17/23

import Foundation

enum CanyonFilePath {
    private static let indexFileName = "index"
    private static let canyonDirectoryName = "CanyonDetails"
    private static let appBundle = Bundle(for: CanyonAPIService.self)
    private static let fileManager = FileManager.default
    
    static var bundleIndexPath: URL {
        get throws {
            guard let indexFilePath = appBundle.url(forResource: Self.indexFileName, withExtension: "json") else {
                Global.logger.error("Failed to find index file in bundle!")
                throw RequestError.serialization
            }
            return indexFilePath
        }
    }
    
    static var bundleCanyonDirectory: URL {
        get throws {
            let indexFileURL = try bundleIndexPath
            let baseDirectory = indexFileURL.deletingLastPathComponent()
            return baseDirectory.appending(component: canyonDirectoryName)
        }
    }
    
    static func bundleCanyonPath(for id: String) throws -> URL {
        return try bundleCanyonDirectory.appending(component: "\(id).json")
    }
    
    static let writableIndexPath: String = {
        let writableDirectory = getDocumentsDirectory()
        return writableDirectory.appendingPathComponent("\(indexFileName).json") as String
    }()

    static let writableCanyonDirectory: String = {
        let writableDirectory = getDocumentsDirectory() as String
        let canyonDirectory = "\(writableDirectory)/\(canyonDirectoryName)"
        return canyonDirectory
    }()

    static func writableCanyonPath(for id: String) -> String {
        return writableCanyonDirectory.appending("/\(id).json")
    }
}
