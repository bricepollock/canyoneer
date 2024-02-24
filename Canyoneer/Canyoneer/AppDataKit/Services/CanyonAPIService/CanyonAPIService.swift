//
//  CanyonAPIService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import MapKit

/// Represents updated data transaction
struct DataUpdate {
    let indexUpdate: CanyonIndexResponse
    let neededCanyonUpdates: [CanyonIndex]
}

struct CanyonIndexResponse {
    let data: Data
    let index: [CanyonIndex]
}

struct CanyonResponse {
    let data: Data
    let canyon: RopeWikiCanyon
}

/// See https://github.com/CanyoneerApp/api for API documentation
protocol CanyonAPIServing {
    /// Get canyon index from server
    func canyonIndex() async throws -> CanyonIndexResponse
    
    /// Get file updates for all canyons from server
    func canyons(for canyonsToFetch: [CanyonIndex], inBackground: Bool) async throws -> [CanyonResponse]
}

class CanyonAPIService: CanyonAPIServing {
    /// The session we use for batch parallelized canyon updates like when we update the whole DB
    internal let batchSession: URLSession = {
        let maxCount = 20
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = maxCount
        config.timeoutIntervalForRequest = 120

        let session = URLSession(configuration: config)
        session.delegateQueue.maxConcurrentOperationCount = maxCount
        return session
    }()
    internal let batchBackgroundSession: URLSession = {
        let maxCount = 20
        let config = URLSessionConfiguration.background(withIdentifier: "backcountry_nomad_background_session")
        config.httpMaximumConnectionsPerHost = maxCount
        config.timeoutIntervalForRequest = 120

        let session = URLSession(configuration: config)
        session.delegateQueue.maxConcurrentOperationCount = maxCount
        return session
    }()
    internal let standardSession = URLSession.shared
    
    func canyonIndex() async throws -> CanyonIndexResponse {
        // Get update
        let decoder = JSONDecoder()
        let request = URLRequest(url: CanyonAPIURL.index)
        
        let data: Data
        do {
            (data, _) = try await self.standardSession.data(for: request)
        } catch {
            throw IndexUpdateError.indexRequest(error.localizedDescription)
        }
        
        let newIndex: [CanyonIndex]
        do {
            newIndex = try decoder.decode([RopeWikiCanyonIndex].self, from: data).map {
                CanyonIndex(data: $0)
            }
        } catch {
            throw IndexUpdateError.indexRequestDecoding(error.localizedDescription)
        }
        
        return CanyonIndexResponse(data: data, index: newIndex)
    }
    
    func canyons(for canyonsToFetch: [CanyonIndex], inBackground: Bool) async throws -> [CanyonResponse] {
        try await requestCanyonsInChunks(canyons: canyonsToFetch, inBackground: inBackground)
    }
    
    /// The goal of this is to maximize parallelization without over extending the device's thread / connection limits.
    /// To do this we chunk all requests into large buckets of parallelization and then execute those buckets serially. This avoids long timeouts
    /// which could cause the whole update to fail. Under ideal conditions, this took 3s for each 1000 canyon chunk.
    ///
    /// ### Why we are not using Task Groups all the way down
    /// If we just added everything to the TaskGroup (and had a full update of 10,000+ canyons needed) then our network requests
    /// will time out as all 10k will be waiting on the URLSession for their turn to fire and get a response.
    /// Given our behavior of not considerig an update successful unless the whole update succeeded and overwriting partials each time...
    /// this gives a high likely of us timing out at least once and the whole thing failing. Under ideal conditions (100MB/s on a computer's simulator)
    /// a 10k update would result in the tail end network requests timing out over the default 60s timeout duration. Even expanding those limits of the number
    /// of parallel network requests and our timeout like we have for `batchSession`, the last network requests would complete in 45s under ideal conditions.
    /// Conditions are anything but ideal on device in the field so this was worrisome an app could get into a state where it would never be able to update because one of 10k
    /// canyons would time out. Similarly, this only gets worse at scale.
    private func requestCanyonsInChunks(canyons: [CanyonIndex], inBackground: Bool) async throws -> [CanyonResponse] {
        let start = Date()
        var canyonUpdates = [CanyonResponse]()
        for chunk in canyons.chunked(into: 1000) {
            let chunkStart = Date()
            canyonUpdates += try await requestCanyonsInParallel(canyons: chunk, inBackground: inBackground)
            let chunkDuration = DateComponentsFormatter.duration(for: -chunkStart.timeIntervalSinceNow)
            Global.logger.debug("Downloaded \(canyonUpdates.count)/\(canyons.count) (\(chunk[0].id) chunk) took \(chunkDuration)")
        }
        let totalDuration = DateComponentsFormatter.duration(for: -start.timeIntervalSinceNow)
        Global.logger.debug("All Downloads complete in \(totalDuration)")
        return canyonUpdates
    }
    
    /// Request these canyons all in parallel
    private func requestCanyonsInParallel(canyons: [CanyonIndex], inBackground: Bool) async throws -> [CanyonResponse] {
        let session = inBackground ? batchBackgroundSession : batchSession
        return try await withThrowingTaskGroup(of: CanyonResponse.self) { group in
            canyons.forEach { canyon in
                _ = group.addTaskUnlessCancelled { [weak self] in
                    guard let self else {
                        throw IndexUpdateError.singleCanyonUpdate("No self")
                    }
                    do {
                        return try await requestCanyon(with: canyon.id, using: session)
                    } catch {
                        let errorMessage: String = "Failed to download canyon for \(canyon.id): \(error)"
                        Global.logger.error("\(errorMessage)")
                        throw IndexUpdateError.singleCanyonUpdate(errorMessage)
                    }
                }
            }
            
            var responses = [CanyonResponse]()
            for try await canyon in group {
                responses.append(canyon)
            }
            return responses
        }
    }
    
    private func requestCanyon(with id: String, using session: URLSession) async throws -> CanyonResponse {
        let decoder = JSONDecoder()
        let request = URLRequest(url: CanyonAPIURL.canyon(with: id))
        let (data, _) = try await session.data(for: request)

        // Ensure it unpacks
        let canyon = try decoder.decode(RopeWikiCanyon.self, from: data)
        
        return CanyonResponse(data: data, canyon: canyon)
    }
}
