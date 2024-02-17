//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
@testable import Canyoneer

@MainActor
class CanyonDataManagerTests: XCTestCase {
    var service: MockCanyonAPIService!
    var manager: CanyonDataManager!
    var fileManager: FileManager! = FileManager.default
    
    override func setUp() {
        super.setUp()
        service = MockCanyonAPIService()
        manager = CanyonDataManager(canyonService: service)
    }
    
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
    
    func testIndexFromBundle() async throws {
        let index = try await manager.loadIndexFromFile()
        XCTAssertEqual(index.count, 10635)
    }
    
    func testReadWriteIndex() async throws {
        let newIndex = [
            RopeWikiCanyonIndex()
        ]
        let converted = newIndex.map { CanyonIndex(data: $0) }
        let data = try JSONEncoder().encode(newIndex)
        let response = CanyonIndexResponse(data: data, index: converted)
        try await manager.writeIndex(response: response)
        
        let index = try await manager.loadIndexFromFile()
        XCTAssertEqual(index.count, newIndex.count)
    }
    
    func testCanyonFromBundle() async throws {
        let canyonID = 40
        let canyon = try await manager.loadCanyonFromFile(id: String(canyonID))
        XCTAssertEqual(canyon.id, canyonID)
    }
    
    func testReadWriteCanyon() async throws {
        // The failure here I think has soemthing to do with somethign not being migrated will have to look into it.
        let canyonID = 40
        let canyon = RopeWikiCanyon(id: String(canyonID), name: "Piton Canyon")
        let data = try JSONEncoder().encode(canyon)
        let response = CanyonResponse(data: data, canyon: canyon)
        try await manager.writeCanyon(response: response, checkDir: true)
        
        let result = try await manager.loadCanyonFromFile(id: String(canyonID))
        XCTAssertEqual(result.name, canyon.name)
    }
    
    func testReadDecode() async throws {
        let canyonID = 6880
        let canyon = try await manager.loadCanyonFromFile(id: String(canyonID))
        
        // Test Decode
        XCTAssertEqual(canyon.urlString, "https://ropewiki.com/Scotty%27s_Canyon")
        XCTAssertEqual(canyon.latitude, 35.9681)
        XCTAssertEqual(canyon.longitude, -116.6582)
        XCTAssertEqual(canyon.id, 6880)
        XCTAssertEqual(canyon.name, "Scotty's Canyon")
        XCTAssertEqual(canyon.quality, 3)
        XCTAssertEqual(canyon.monthStringList, ["Nov","Dec","Jan","Feb","Mar"])
        XCTAssertEqual(canyon.technicalRatingRaw, 3)
        XCTAssertEqual(canyon.waterRatingString, "A")
        XCTAssertEqual(canyon.timeRatingString, "III")
        XCTAssertEqual(canyon.permitString, "No")
        XCTAssertEqual(canyon.rappelCountMin, 8)
        XCTAssertEqual(canyon.rappelCountMax, 8)
        XCTAssertEqual(canyon.rappelLongestMeters, 30.48)
        XCTAssertTrue(canyon.htmlDescription?.contains("SCOTTY'S CANYON WITH RICK KENT") ?? false)
        XCTAssertEqual(canyon.version, "d428d51485d00ceaacf4631440fb242a")
        
        // Test Translation
        XCTAssertEqual(canyon.urlString, "https://ropewiki.com/Scotty%27s_Canyon")
        XCTAssertEqual(canyon.latitude, 35.9681)
        XCTAssertEqual(canyon.longitude, -116.6582)
        XCTAssertEqual(canyon.id, 6880)
        XCTAssertEqual(canyon.name, "Scotty's Canyon")
        XCTAssertEqual(canyon.quality, 3)
        
        XCTAssertEqual(canyon.technicalRating, .three)
        XCTAssertNil(canyon.riskRating)
        XCTAssertEqual(canyon.waterRating, .a)
        XCTAssertEqual(canyon.timeRating, .three)
        XCTAssertEqual(canyon.bestMonths, [.november,.december,.january,.february,.march])
        XCTAssertNil(canyon.vehicleAccessibility)
    }
    
    func testReadDecode_risk_vehicle() async throws {
        let canyonID = 322
        let canyon = try await manager.loadCanyonFromFile(id: String(canyonID))
        
        XCTAssertEqual(canyon.quality, 4.4)
        XCTAssertEqual(canyon.vehicleString, "High Clearance")
        XCTAssertEqual(canyon.vehicleAccessibility, .highClearance)
        
        XCTAssertEqual(canyon.riskRatingString, "R")
        XCTAssertEqual(canyon.riskRating, .r)
    }
    
    func testReadDecode_shuttle() async throws {
        let canyonID = 49
        let canyon = try await manager.loadCanyonFromFile(id: String(canyonID))
        
        XCTAssertEqual(canyon.technicalRating, .four)
        XCTAssertEqual(canyon.waterRating, .c)
        XCTAssertEqual(canyon.timeRating, .four)
        XCTAssertEqual(canyon.shuttleInSeconds, 30)
        XCTAssertEqual(canyon.vehicleString, "Passenger")
        XCTAssertEqual(canyon.vehicleAccessibility, .passenger)
    }
    
    func testReadDecode_permit() async throws {
        let canyonID = 15683
        let canyon = try await manager.loadCanyonFromFile(id: String(canyonID))
        
        XCTAssertEqual(canyon.technicalRating, .three)
        XCTAssertEqual(canyon.waterRating, .b)
        XCTAssertEqual(canyon.timeRating, .two)
        XCTAssertEqual(canyon.permitString, "Yes")
        XCTAssertEqual(canyon.permit, .required)
    }
    
    func testPopulate() async {
        let canyons = [
            CanyonIndex(permit: .required),
            CanyonIndex(permit: .notRequired),
            CanyonIndex(permit: .closed)
        ]
        await manager.populate(from: canyons)
        let populated = await manager.canyons()
        XCTAssertEqual(populated.count, 2)
    }
    
    func testFindCanyonsNeedUpdate() async throws {
        let canyons = [
            CanyonIndex(),
            CanyonIndex(),
            CanyonIndex()
        ]
        await manager.populate(from: canyons)
        
        let existingCanyon = canyons[1]
        let needsUpdateCanyon = CanyonIndex(id: existingCanyon.id)
        service.mockIndex = CanyonIndexResponse(data: Data(), index: [needsUpdateCanyon])
        let update = try await manager.canyonsRequiringUpdate()
        XCTAssertEqual(update?.neededCanyonUpdates.count, 1)
    }
}
