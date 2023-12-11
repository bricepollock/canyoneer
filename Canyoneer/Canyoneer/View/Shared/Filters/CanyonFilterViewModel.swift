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
    
    func reset() {
        let resetState = FilterState.default
        
        if self.maxRap != resetState.maxRap {
            self.maxRap = resetState.maxRap
        }
        
        if self.numRaps != resetState.numRaps {
            self.numRaps = resetState.numRaps
        }
        
        if self.stars != resetState.stars {
            self.stars = resetState.stars
        }
        
        if self.technicality != resetState.technicality {
            self.technicality = resetState.technicality
        }
        
        if self.water != resetState.water {
            self.water = resetState.water
        }
        
        if self.shuttleRequired != resetState.shuttleRequired {
            self.shuttleRequired = resetState.shuttleRequired
        }
        
        if self.seasons != resetState.seasons {
            self.seasons = resetState.seasons
        }
    }
    
    func filter(results: [QueryResult], with state: FilterState) -> [QueryResult] {
        let canyons = results.compactMap { $0.canyonDetails }
        return Self.filter(canyons: canyons, given: state).map {
            return QueryResult(name: $0.name, canyonDetails: $0)
        }
    }
    
    static func filter(canyons: [Canyon], given state: FilterState) -> [Canyon] {
        // Used to compare if we should apply a filter at all
        let defaultFilter = FilterState.default
        return canyons.filter { canyon in
            // quality
            guard state.stars.contains(Int(canyon.quality)) else {
                return false
            }
            
            // num raps
            if state.numRaps != defaultFilter.numRaps {
                guard let numRaps = canyon.numRaps else {
                    return false
                }
                guard numRaps >= state.numRaps.min && numRaps <= state.numRaps.max else {
                    return false
                }
            }
            
            // max rap
            if state.maxRap != defaultFilter.maxRap {
                guard let maxRap = canyon.maxRapLength else { return false }
                guard maxRap >= state.maxRap.min && maxRap <= state.maxRap.max else {
                    return false
                }
            }
            
            // technical
            if state.technicality != defaultFilter.technicality {
                guard let technicalRating = canyon.technicalDifficulty else { return false }
                guard state.technicality.contains(technicalRating) else {
                    return false
                }
            }
            
            // water
            if state.water != defaultFilter.water {
                guard let waterDifficulty = canyon.waterDifficulty else { return false }
                guard state.water.contains(waterDifficulty) else {
                    return false
                }
            }
            
            // Time
            if state.time != defaultFilter.time {
                guard let time = canyon.timeGrade else { return false}
                guard state.time.contains(time) else {
                    return false
                }
            }
            
            // Shuttle (bypass any)
            if let filterRequireShuttle = state.shuttleRequired, state.shuttleRequired != defaultFilter.shuttleRequired {
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
            if state.seasons != defaultFilter.seasons {
                guard Set(canyon.bestSeasons).intersection(state.seasons).count > 0 else {
                    return false
                }
            }

            
            // end
            return true
        }
    }
    
}
