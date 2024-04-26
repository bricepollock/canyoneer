//  Created by Brice Pollock for Canyoneer on 12/10/23

import Foundation

protocol CanyonPreview: Identifiable, Equatable {
    var id: String { get }
    var name: String { get }
    var coordinate: Coordinate { get }
    var technicalDifficulty: TechnicalGrade? { get }
    var risk: Risk? { get }
    var timeGrade: TimeGrade? { get }
    var waterDifficulty: WaterGrade? { get }
    var minRaps: Int? { get }
    var maxRaps: Int? { get }
    /// Meters
    var maxRapLength: Measurement<UnitLength>? { get }
    var bestSeasons: [Month] { get }
    var permit: Permit? { get }
    /// Seconds
    var shuttleDuration: Measurement<UnitDuration>? { get }
    /// 0 = Not rated
    /// Otherwise 1 -> 5
    var quality: Double { get }
    var vehicleAccessibility: Vehicle? { get }
    var version: String { get }
}

extension CanyonPreview {
    /// Not all states are perfectly known
    /// * State: No shuttle required = null
    /// * State: Requires shuttle, but no duration: ??
    /// * State: Requires shuttle, but has duration = any number
    var requiresShuttle: Bool {
        shuttleDuration != nil
    }
    
    var requiresPermits: Bool? {
        guard let permit else { return nil }
        return permit != .notRequired
    }
    
    var isRestricted: Bool? {
        guard let permit else { return nil }
        return permit == .restricted
    }
    
    var isClosed: Bool {
        guard let permit else { return false }
        return permit == .closed
    }
    
    var numRappelsAsString: String? {
        if let min = minRaps, let max = maxRaps, min != max {
            return "\(min)-\(max)r"
        } else if let singleNumber = minRaps ?? maxRaps {
            return "\(singleNumber)r"
        } else {
            return nil
        }
    }
}
