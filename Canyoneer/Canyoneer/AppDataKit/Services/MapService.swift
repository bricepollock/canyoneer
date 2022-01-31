//
//  MapService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/14/22.
//

import Foundation
import MapboxMaps
import UIKit
import Combine

struct MapService {
    public static let shared = MapService()
    
    public var downloadProgress: AnyPublisher<Float, Never> {
        return self.downloadProgressSubject.eraseToAnyPublisher()
    }
    private let downloadProgressSubject = PassthroughSubject<Float, Never>()
    
    public static let publicAccessToken = "pk.eyJ1IjoiYnJpY2Vwb2xsb2NrIiwiYSI6ImNreWRhdGNtODAyNzUyb2xoMXdmbWFvd3UifQ.-iGgCZKoYX9wKf5uAyLWHA"
    private let tileStore = TileStore.default
    private let offlineManager: OfflineManager
    
    private init() {
        self.tileStore.setOptionForKey(TileStoreOptions.mapboxAccessToken, value: Self.publicAccessToken as Any)
        self.offlineManager = OfflineManager(resourceOptions: ResourceOptions(accessToken: Self.publicAccessToken, tileStore: tileStore))
    }
    
    func hasDownloaded(all canyons: [Canyon]) -> AnyPublisher<Bool, Error> {
        let ids = canyons.map { $0.id }
        let subject = PassthroughSubject<Bool, Error>()
        
        self.tileStore.allTileRegions { result in
            switch result {
            case let .success(regions):
                let regionIds = regions.map { $0.id }
                if Set(ids).intersection(regionIds).count == ids.count {
                    subject.send(true)
                } else {
                    subject.send(false)
                }
            case let .failure(error):
                Global.logger.error(error)
                subject.send(completion: .failure(error))
            }
        }
        return subject.eraseToAnyPublisher()
    }
        
    func downloadTile(for canyon: Canyon) -> AnyPublisher<Void, Error> {
        let id = canyon.id
        let options = TilesetDescriptorOptions(styleURI: .outdoors, zoomRange: 8...16)
        let tilesetDescriptor = offlineManager.createTilesetDescriptor(for: options)
        
        let publisher = PassthroughSubject<Void, Error>()
        guard let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: .point(Point(LocationCoordinate2D(latitude: canyon.coordinate.latitude, longitude: canyon.coordinate.longitude))),
            descriptors: [tilesetDescriptor],
            acceptExpired: true
        ) else {
            Global.logger.error("Could not create tile region!")
            publisher.send(completion: .failure(RequestError.noResponse))
            return publisher.eraseToAnyPublisher()
        }
        
        _ = tileStore.loadTileRegion(
            forId: id,
            loadOptions: tileRegionLoadOptions) { _ in
                // progress callback
        } completion: { result in
            switch result {
            case let .success(tileRegion):
                _ = tileRegion // removes warning, may want this object in future
                Global.logger.info("Finished downloading tile for \(id)")
                publisher.send(())
            case let .failure(error):
                // Handle error occurred during the tile region download
                if case TileRegionError.canceled = error {
                    Global.logger.debug("The tile request was canceled")
                } else {
                    Global.logger.error(error)
                }
                publisher.send(completion: .failure(error))
            }
        }
        return publisher.eraseToAnyPublisher()
    }
    
    func downloadTiles(for canyons: [Canyon]) -> AnyPublisher<Void, Error> {
        let totalDownloads = Float(canyons.count)
        var downloaded: Float = 0
        self.downloadProgressSubject.send(0)
        let publishers = canyons.map {
            self.downloadTile(for: $0)
                .handleEvents(receiveOutput: { _ in
                    downloaded += 1
                    let downloadPercentage = downloaded / totalDownloads
                    DispatchQueue.main.async {
                        self.downloadProgressSubject.send(downloadPercentage)
                    }
                })
        }
        
        return ZipCollection(publishers)
            .map { _ in return () }
            .handleEvents(receiveOutput: { _ in
                DispatchQueue.main.async {
                    self.downloadProgressSubject.send(1)
                }
            }, receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    Global.logger.error(error)
                    DispatchQueue.main.async {
                        self.downloadProgressSubject.send(1)
                    }
                default: break;
                }
            }).eraseToAnyPublisher()
    }
}
