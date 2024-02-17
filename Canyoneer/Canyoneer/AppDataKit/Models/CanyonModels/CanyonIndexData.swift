//  Created by Brice Pollock for Canyoneer on 12/10/23

/// Canyon index representation in V2 format
protocol CanyonIndexData: Codable {
    var id: Int { get }
    var name: String { get }
    var quality: Double? { get }
    var monthStringList: [String]? { get }
    var technicalRatingRaw: Int? { get }
    var waterRatingString: String? { get }
    var timeRatingString: String? { get }
    var riskRatingString: String? { get }
    var permitString: String? { get }
    var rappelCountMin: Int? { get }
    var rappelCountMax: Int? { get }
    var rappelLongestMeters: Double? { get }
    var vehicleString: String? { get }
    var shuttleInSeconds: Double? { get }
    var latitude: Double { get }
    var longitude: Double { get }
    var version: String { get }
}

extension CanyonIndexData {
    var technicalRating: TechnicalGrade? {
        guard let technicalRatingRaw else { return nil }
        return TechnicalGrade(data: technicalRatingRaw)
    }
    
    var riskRating: Risk? {
        guard let riskRatingString else { return nil }
        return Risk(rawValue: riskRatingString)
    }
    
    var waterRating: WaterGrade? {
        WaterGrade(data: waterRatingString)
    }
    
    var timeRating: TimeGrade? {
        TimeGrade(data: timeRatingString)
    }
    
    var bestMonths: [Month] {
        monthStringList?.compactMap {
            return Month(short: $0)
        } ?? []
    }
    
    var vehicleAccessibility: Vehicle? {
        guard let vehicleString else { return nil }
        return Vehicle(rawValue: vehicleString)
    }
    
    var permit: Permit? {
        guard let permitString else { return nil }
        return Permit(rawValue: permitString)
    }
}
