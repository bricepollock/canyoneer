//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
@testable import Canyoneer

class CanyonFilePathTests: XCTestCase {
    var fileManager: FileManager! = FileManager.default
    
    override func tearDown() async throws {
        let indexPath = CanyonFilePath.writableIndexPath
        if fileManager.fileExists(atPath: indexPath) {
            try fileManager.removeItem(at: URL(filePath: indexPath))
        }
        
        let canyonDetailsDir = CanyonFilePath.writableCanyonDirectory
        if fileManager.fileExists(atPath: canyonDetailsDir) {
            try fileManager.removeItem(at: URL(filePath: canyonDetailsDir))
        }
    }
    
    func testBundleIndexPath() throws {
        let path = try CanyonFilePath.bundleIndexPath
        XCTAssertTrue(path.absoluteString.hasSuffix("/index.json"))
    }
    
    func testBundleCanyonDirectory() throws {
        let path = try CanyonFilePath.bundleCanyonDirectory
        XCTAssertTrue(path.absoluteString.hasSuffix("/CanyonDetails"))
    }
    
    func testBundleCanyonPath() throws {
        let path = try CanyonFilePath.bundleCanyonPath(for: "123")
        XCTAssertTrue(path.absoluteString.hasSuffix("/CanyonDetails/123.json"))
    }
    
    func testWritableIndexPath() throws {
        let path = CanyonFilePath.writableIndexPath
        XCTAssertTrue(path.hasSuffix("/index.json"), "Failed URL: \(path)")
        
        XCTAssertFalse(fileManager.fileExists(atPath: path))
        try "anything".data(using: .unicode)?.write(to: URL(filePath: path))
        XCTAssertTrue(fileManager.fileExists(atPath: path))
        XCTAssertTrue(fileManager.isWritableFile(atPath: path))
    }
    
    func testWritableCanyonDirectory() throws {
        let path = CanyonFilePath.writableCanyonDirectory
        XCTAssertTrue(path.hasSuffix("/CanyonDetails"), "Failed URL: \(path)")
        
        XCTAssertFalse(fileManager.fileExists(atPath: path))
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        XCTAssertTrue(fileManager.fileExists(atPath: path))
        XCTAssertTrue(fileManager.isWritableFile(atPath: path))
    }
    
    func testWritableCanyonPath() throws {
        let path = CanyonFilePath.writableCanyonPath(for: "123")
        XCTAssertTrue(path.hasSuffix("/CanyonDetails/123.json"), "Failed URL: \(path)")
        
        XCTAssertFalse(fileManager.fileExists(atPath: path))
        try fileManager.createDirectory(atPath: CanyonFilePath.writableCanyonDirectory, withIntermediateDirectories: true)
        try "anything".data(using: .unicode)?.write(to: URL(filePath: path))
        XCTAssertTrue(fileManager.fileExists(atPath: path))
        XCTAssertTrue(fileManager.isWritableFile(atPath: path))
    }
}
