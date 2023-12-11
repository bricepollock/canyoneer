//
//  Canyon.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

struct Canyon {
    let id: String
    let index: CanyonIndex
    /// Optional to support other data sources in future
    let ropeWikiURL: URL?
    /// HTML String
    let description: String
    let geoWaypoints: [CoordinateFeature]
    let geoLines: [CoordinateFeature]
    
    /// This data in its codable form
    let asCodable: RopeWikiCanyon
    
    init(data: RopeWikiCanyon) {
        let index = CanyonIndex(data: data)
        self.id = index.id
        self.index = index
        self.ropeWikiURL = URL(string: data.urlString)
        self.description = data.htmlDescription ?? ""
        
        let features = data.geoJson?.features ?? []
        let geoFeatures: [CoordinateFeature] = features.compactMap {
            return CoordinateFeature(
                name: $0.properties.name,
                type: $0.geometry.type,
                hexColor: $0.properties.color,
                coordinates: $0.geometry.coordinates
            )
        }
        self.geoWaypoints = geoFeatures.filter { $0.type == .waypoint }
        self.geoLines = GPXService.simplify(features: geoFeatures.filter { $0.type == .line })
        
        self.asCodable = data
    }
    
    init(legacy: LegacyCanyon) {
        let maxRapLength: Measurement<UnitLength>?
        if let rappelLongestMeters = legacy.maxRapLength {
            var longest = Measurement(value: Double(rappelLongestMeters), unit: UnitLength.feet)
            longest.convert(to: .meters)
            maxRapLength = longest
        } else {
            maxRapLength = nil
        }
        
        let permit: Permit?
        if legacy.isRestricted == true {
            permit = .restricted
        } else if legacy.requiresShuttle == true {
            permit = .required
        } else if legacy.requiresShuttle == false {
            permit = .notRequired
        } else {
            permit = nil
        }
        let shuttleDuration = legacy.requiresShuttle == true ? Measurement(value: 0, unit: UnitDuration.seconds) : nil
        self.init(
            id: legacy.id,
            name: legacy.name,
            coordinate: legacy.coordinate,
            technicalDifficulty: legacy.technicalDifficulty,
            risk: legacy.risk,
            timeGrade: legacy.timeGrade,
            waterDifficulty: legacy.waterDifficulty,
            minRaps: legacy.numRaps,
            maxRaps: legacy.numRaps,
            maxRapLength: maxRapLength,
            bestSeasons: legacy.bestSeasons,
            permit: permit,
            shuttleDuration: shuttleDuration,
            quality: Double(legacy.quality),
            vehicleAccessibility: legacy.vehicleAccessibility,
            url: legacy.ropeWikiURL,
            description: legacy.description,
            geoWaypoints: legacy.geoWaypoints,
            geoLines: legacy.geoLines
        )
    }
    
    /// - Warning: Should only be used in previews and testing, not properly configured for codable
    init(
        id: String = "101",
        name: String = "Moonflower Canyon",
        coordinate: Coordinate = Coordinate(latitude: 1, longitude: 1),
        technicalDifficulty: TechnicalGrade? = .three,
        risk: Risk? = nil,
        timeGrade: TimeGrade? = .two,
        waterDifficulty: WaterGrade? = .a,
        minRaps: Int? = 2,
        maxRaps: Int? = 2,
        maxRapLength: Measurement<UnitLength>? = Measurement(value: 67.056, unit: .meters),
        bestSeasons: [Month] = [.march, .april, .may, .june, .july, .august, .september],
        permit: Permit? = nil,
        shuttleDuration: Measurement<UnitDuration>? = nil,
        quality: Double = 4.3,
        vehicleAccessibility: Vehicle? = .passenger,
        url: URL? = URL(string: "http://ropewiki.com/Moonflower_Canyon")!,
        description: String = "<b>This is a canyon</b>",
        geoWaypoints: [CoordinateFeature] = [],
        geoLines: [CoordinateFeature] = []
    ) {
        self.id = id
        self.index = CanyonIndex(
            id: id,
            name: name,
            coordinate: coordinate,
            technicalDifficulty: technicalDifficulty,
            risk: risk,
            timeGrade: timeGrade,
            waterDifficulty: waterDifficulty,
            minRaps: minRaps,
            maxRaps: maxRaps,
            maxRapLength: maxRapLength,
            bestSeasons: bestSeasons,
            permit: permit,
            shuttleDuration: shuttleDuration,
            quality: quality,
            vehicleAccessibility: vehicleAccessibility
        )
        self.ropeWikiURL = url
        self.description = description
        self.geoWaypoints = geoWaypoints
        self.geoLines = geoLines
        
        self.asCodable = RopeWikiCanyon(
            id: id,
            name: name,
            coordinate: coordinate,
            technicalDifficulty: technicalDifficulty,
            risk: risk,
            timeGrade: timeGrade,
            waterDifficulty: waterDifficulty,
            minRaps: minRaps,
            maxRaps: maxRaps,
            maxRapLength: maxRapLength,
            bestSeasons: bestSeasons,
            permit: permit,
            shuttleDuration: shuttleDuration,
            quality: quality,
            vehicleAccessibility: vehicleAccessibility,
            url: url,
            description: description,
            geoWaypoints: geoWaypoints,
            geoLines: geoLines
        )
    }
}

extension Canyon: CanyonPreview {
    var name: String { index.name }
    var coordinate: Coordinate { index.coordinate }
    var technicalDifficulty: TechnicalGrade? { index.technicalDifficulty }
    var risk: Risk? { index.risk }
    var timeGrade: TimeGrade? { index.timeGrade }
    var waterDifficulty: WaterGrade? { index.waterDifficulty }
    var minRaps: Int? { index.minRaps }
    var maxRaps: Int? { index.maxRaps }
    var maxRapLength: Measurement<UnitLength>? { index.maxRapLength }
    var bestSeasons: [Month] { index.bestSeasons }
    var permit: Permit? { index.permit }
    var shuttleDuration: Measurement<UnitDuration>? { index.shuttleDuration }
    var quality: Double { index.quality }
    var vehicleAccessibility: Vehicle? { index.vehicleAccessibility }
}

extension Canyon: Identifiable, Equatable {
    static func == (lhs: Canyon, rhs: Canyon) -> Bool {
        lhs.id == rhs.id
    }
}
