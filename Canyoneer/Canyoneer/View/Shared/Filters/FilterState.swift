//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation

struct FilterState {
    /// Maximum rappel lengths, in feet
    let maxRap: Bounds
    let numRaps: Bounds
    let stars: Set<Int>
    let technicality: Set<TechnicalGrade>
    let water: Set<WaterGrade>
    let time: Set<TimeGrade>
    let shuttleRequired: Bool?
    let seasons: Set<Month>
    
    public static let `default` = FilterState(
        maxRap: Bounds(min: 0, max: Int(FilterState.maxRapLimit.converted(to: .feet).value.rounded())),
        numRaps: Bounds(min: 0, max: FilterState.numRapsLimit),
        stars: [1,2,3,4,5],
        technicality: Set(TechnicalGrade.allCases),
        water: Set(WaterGrade.allCases),
        time: Set(TimeGrade.allCases),
        shuttleRequired: nil,
        seasons: Set(Month.allCases)
    )
    
    private static let maxRapLimit = Measurement(value: 600, unit: UnitLength.feet)
    public static let maxRapIncrement = Measurement(value: 10, unit: UnitLength.feet)
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
