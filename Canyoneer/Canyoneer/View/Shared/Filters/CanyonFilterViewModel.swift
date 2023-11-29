//
//  FilterViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation

struct FilterState {
    let maxRap: Bounds // In FT
    let numRaps: Bounds
    let stars: Set<Int>
    let technicality: Set<TechnicalGrade>
    let water: Set<WaterGrade>
    let time: Set<TimeGrade>
    let shuttleRequired: Bool?
    let seasons: Set<Month>
    
    public static let `default` = FilterState(
        maxRap: Bounds(min: 0, max: FilterState.maxRapLimit),
        numRaps: Bounds(min: 0, max: FilterState.numRapsLimit),
        stars: [1,2,3,4,5],
        technicality: Set(TechnicalGrade.allCases),
        water: Set(WaterGrade.allCases),
        time: Set(TimeGrade.allCases),
        shuttleRequired: nil,
        seasons: Set(Month.allCases)
    )
    
    private static let maxRapLimit: Int = 600  // In FT
    public static let maxRapIncrement: Int = 10  // In FT
    private static let numRapsLimit: Int = 50
    public static let numRapsIncrement: Int = 1
    
    // Default params just used for testing
    init(
        maxRap: Bounds = FilterState.default.maxRap,
        numRaps: Bounds = FilterState.default.numRaps,
        stars: Set<Int> = FilterState.default.stars,
        technicality: Set<TechnicalGrade> = FilterState.default.technicality,
        water: Set<WaterGrade> = FilterState.default.water,
        time: Set<TimeGrade> = FilterState.default.time,
        shuttleRequired: Bool? = FilterState.default.shuttleRequired,
        seasons: Set<Month> = FilterState.default.seasons
    ) {
        self.maxRap = maxRap
        self.numRaps = numRaps
        self.stars = stars
        self.technicality = technicality
        self.water = water
        self.time = time
        self.shuttleRequired = shuttleRequired
        self.seasons = seasons
    }
}

@MainActor
class CanyonFilterViewModel: ObservableObject {
    // Compiled
    @Published private(set) public var currentState: FilterState
    
    // Filters
    @Published var maxRap: Bounds
    @Published var numRaps: Bounds
    @Published var stars: Set<Int>
    @Published var technicality: Set<TechnicalGrade>
    @Published var water: Set<WaterGrade>
    @Published var time: Set<TimeGrade>
    @Published var shuttleRequired: Bool?
    @Published var seasons: Set<Month>
    
    init(initialState: FilterState) {
        self.maxRap = initialState.maxRap
        self.numRaps = initialState.numRaps
        self.stars = initialState.stars
        self.technicality = initialState.technicality
        self.water = initialState.water
        self.time = initialState.time
        self.shuttleRequired = initialState.shuttleRequired
        self.seasons = initialState.seasons
        self.currentState = initialState
        
        self.$maxRap
            .combineLatest($numRaps, $stars, $technicality)
            .combineLatest($water, $time, $shuttleRequired)
            .combineLatest($seasons)
            .map { (combined, seasons) in
                let (((maxRap), numRaps, stars, technicality), water, time, shuttleRequired) = combined
                return FilterState(
                    maxRap: maxRap,
                    numRaps: numRaps,
                    stars: stars,
                    technicality: technicality,
                    water: water,
                    time: time,
                    shuttleRequired: shuttleRequired,
                    seasons: seasons
                )
            }.assign(to: &$currentState)
    }
    
    func reset(to state: FilterState) {
        self.maxRap = state.maxRap
        self.numRaps = state.numRaps
        self.stars = state.stars
        self.technicality = state.technicality
        self.water = state.water
        self.time = state.time
        self.shuttleRequired = state.shuttleRequired
        self.seasons = state.seasons
    }
    
    func filter(results: [QueryResult]) -> [QueryResult] {
        let canyons = results.compactMap { $0.canyonDetails }
        return self.filter(canyons: canyons).map {
            return QueryResult(name: $0.name, canyonDetails: $0)
        }
    }
    
    func filter(canyons: [Canyon]) -> [Canyon] {
        return canyons.filter { canyon in
            // quality
            guard currentState.stars.contains(Int(canyon.quality)) else {
                return false
            }
            
            // num raps
            guard let numRaps = canyon.numRaps else { return false }
            guard numRaps >= self.numRaps.min && numRaps <= self.numRaps.max else {
                return false
            }
            
            // max rap
            guard let maxRap = canyon.maxRapLength else { return false }
            guard maxRap >= self.maxRap.min && maxRap <= self.maxRap.max else {
                return false
            }
            
            // technical
            guard let technicalRating = canyon.technicalDifficulty else { return false }
            guard self.technicality.contains(technicalRating) else {
                return false
            }
            
            // water
            guard let waterDifficulty = canyon.waterDifficulty else { return false }
            guard self.water.contains(waterDifficulty) else {
                return false
            }
            
            // Time
            guard let time = canyon.timeGrade else { return false}
            guard self.time.contains(time) else {
                return false
            }
            
            // Shuttle (bypass any)
            if let filterRequireShuttle = self.shuttleRequired {
                // Don't count canyons without shuttle information
                if let requireShuttle = canyon.requiresShuttle {
                    guard requireShuttle == filterRequireShuttle else {
                        return false
                    }
                // if there is no shuttle information then consider this false
                } else if filterRequireShuttle {
                    return false
                }
            }

            
            // Season, if any seasons match up
            let bestSeasonsInitials = canyon.bestSeasons.map { $0.short }
            let filterBestSeasons = self.seasons.map { $0.short }
            guard Set(bestSeasonsInitials).intersection(filterBestSeasons).count > 0 else {
                return false
            }
            
            // end
            return true
        }
    }
    
}
