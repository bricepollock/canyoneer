//
//  MapService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/14/22.
//

import Foundation
import MapboxMaps
import UIKit

@MainActor
class MapService {
    /// Percentage of progress complete
    @Published public var downloadPercentage: Double? = nil
    
    private let tileStore: TileStore
    private let offlineManager: OfflineManager
    
    init() {
        self.tileStore = TileStore.default
        MapboxMapsOptions.tileStore = tileStore
        self.offlineManager = OfflineManager()
    }
    
    func hasDownloaded(all canyons: [Canyon]) async throws -> Bool {
        let canyonIds = canyons.map { $0.id }
        return try await withCheckedThrowingContinuation { continuation in
            self.tileStore.allTileRegions { result in
                switch result {
                case let .success(regions):
                    let regionIds = regions.map { $0.id }
                    if Set(canyonIds).intersection(regionIds).count == canyonIds.count {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                case let .failure(error):
                    Global.logger.error(error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
        
    func downloadTile(for canyon: Canyon) async throws {
        let id = canyon.id
//        let tilesets = ["mapbox://mapbox.mapbox-streets-v8"]
        let options = TilesetDescriptorOptions(styleURI: .outdoors, zoomRange: 8...16, tilesets: nil)
        let tilesetDescriptor = offlineManager.createTilesetDescriptor(for: options)
        
        guard let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: .point(Point(LocationCoordinate2D(latitude: canyon.coordinate.latitude, longitude: canyon.coordinate.longitude))),
            descriptors: [tilesetDescriptor],
            acceptExpired: true
        ) else {
            Global.logger.error("Could not create tile region!")
            throw RequestError.noResponse
        }
        
        try await withCheckedThrowingContinuation { continuation in
            _ = tileStore.loadTileRegion(
                forId: id,
                loadOptions: tileRegionLoadOptions) { _ in
                    // progress callback
            } completion: { result in
                switch result {
                case let .success(tileRegion):
                    _ = tileRegion // removes warning, may want this object in future
                    Global.logger.info("Finished downloading tile for \(id)")
                    continuation.resume()
                case let .failure(error):
                    // Handle error occurred during the tile region download
                    if case TileRegionError.canceled = error {
                        Global.logger.debug("The tile request was canceled")
                    } else {
                        Global.logger.error(error)
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func downloadTiles(for canyons: [Canyon]) async throws {
        let downloadProgress = Progress()
        try await withThrowingTaskGroup(of: Void.self) { group in
            canyons.forEach { canyon in
                downloadProgress.totalUnitCount += 1
                _ = group.addTaskUnlessCancelled { [weak self] in
                    guard let self else { return }
                    try await self.downloadTile(for: canyon)
                }
            }
            for try await _ in group {
                downloadProgress.completedUnitCount += 1
                downloadPercentage = downloadProgress.fractionCompleted
            }
        }
    }
}
