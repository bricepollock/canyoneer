//
//  FilterViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import RxSwift

struct FilterState {
    enum Strings {
        static let a = "A"
        static let b = "B"
        static let c = "C"
    }
    
    var maxRap: (max: Int, min: Int)
    var numRaps: (max: Int, min: Int)
    var stars: [Int]
    var technicality: [Int]
    var water: [String]
    var time: [RomanNumeral]
    var shuttleRequired: Bool?
    var seasons: [Month]
    
    public static let `default` = FilterState(
        maxRap: (max: 600, min: 0),
        numRaps: (max: 50, min: 0),
        stars: [1,2,3,4,5],
        technicality: [1,2,3,4],
        water: [Strings.a, Strings.b, Strings.c],
        time: RomanNumeral.allCases,
        shuttleRequired: nil,
        seasons: Month.allCases
    )
}

class FilterViewModel {
    public let state: Observable<FilterState>
    private let stateSubject: PublishSubject<FilterState>

    private var currentState: FilterState
    
    init() {
        self.stateSubject = PublishSubject()
        self.state = self.stateSubject.asObservable()
        self.currentState = FilterState.default
    }
    
    // MARK: Actions
    
    public func filter(results: [SearchResult]) -> [SearchResult] {
        let canyons = results.compactMap { $0.canyonDetails }
        let filtered = Self.filter(canyons: canyons, against: self.currentState)
        return filtered.map {
            return SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)
        }
    }
    
    public func reset() {
        self.currentState = FilterState.default
        self.stateSubject.onNext(self.currentState)
    }
    
    public func update(maxRap: (max: Int, min: Int)) {
        self.currentState.maxRap = maxRap
        self.stateSubject.onNext(self.currentState)
    }
    
    public func update(numRaps: (max: Int, min: Int)) {
        self.currentState.numRaps = numRaps
        self.stateSubject.onNext(self.currentState)
    }
    
    public func update(stars: [String]) {
        self.currentState.stars = stars.compactMap { Int($0) }
        self.stateSubject.onNext(self.currentState)
    }
    
    public func update(technicality: [String]) {
        self.currentState.technicality = technicality.compactMap { Int($0) }
        self.stateSubject.onNext(self.currentState)
    }
    
    public func update(water: [String]) {
        self.currentState.water = water
        self.stateSubject.onNext(self.currentState)
    }
    
    public func update(time: [String]) {
        self.currentState.time = time.compactMap { RomanNumeral(rawValue: $0) }
        self.stateSubject.onNext(self.currentState)
    }
    
    public func update(shuttle: String?) {
        let required: Bool?
        guard let shuttle = shuttle else {
            Global.logger.error("Unable to decode shuttle for filter")
            return // invalid
        }
        if shuttle == SwitchFilter.Strings.any {
            required = nil
        } else {
            required = shuttle == SwitchFilter.Strings.yes
        }
        self.currentState.shuttleRequired = required
        self.stateSubject.onNext(self.currentState)
    }
    
    public func update(seasons: [String]) {
        self.currentState.seasons = seasons.compactMap { Month(short: $0) }
        self.stateSubject.onNext(self.currentState)
    }
    
    internal static func filter(canyons: [Canyon], against filters: FilterState) -> [Canyon] {
        return canyons.filter { canyon in
            // quality
            guard filters.stars.contains(Int(canyon.quality)) else {
                return false
            }
            
            // num raps
            guard let numRaps = canyon.numRaps else { return false }
            guard numRaps >= filters.numRaps.min && numRaps <= filters.numRaps.max else {
                return false
            }
            
            // max rap
            guard let maxRap = canyon.maxRapLength else { return false }
            guard maxRap >= filters.maxRap.min && maxRap <= filters.maxRap.max else {
                return false
            }
            
            // technical
            guard let technicalRating = canyon.technicalDifficulty else { return false }
            guard filters.technicality.contains(technicalRating) else {
                return false
            }
            
            // water
            guard let waterDifficulty = canyon.waterDifficulty else { return false }
            guard filters.water.contains(waterDifficulty) else {
                return false
            }
            
            // Time
            guard let time = canyon.timeGrade else { return false}
            guard filters.time.map({ $0.rawValue }).contains(time) else {
                return false
            }
            
            // Shuttle (bypass any)
            if let filterRequireShuttle = filters.shuttleRequired {
                
                // Don't count canyons without shuttle information
                if let requireShuttle = canyon.requiresShuttle {
                    guard requireShuttle == filterRequireShuttle else {
                        return false
                    }
                // if there is no shuttle information  then filter out
                } else {
                    return false
                }
            }

            
            // Season, if any seasons match up
            let bestSeasonsInitials = canyon.bestSeasons.map { $0.short }
            let filterBestSeasons = filters.seasons.map { $0.short }
            guard Set(bestSeasonsInitials).intersection(filterBestSeasons).count > 0 else {
                return false
            }
            
            // end
            return true
        }
    }
    
}
