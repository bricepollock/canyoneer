//
//  RopewikiCanyon.swift
//  Canyoneer
//
//  Created by Brice Pollock on 2/5/22.
//

import Foundation

struct RopewikiLoationResponse: Codable {
    let query: RopewikiLocationQuery
}

struct RopewikiLocationQuery: Codable {
    let results: [String: RopewikiCanyon]
}

struct RopewikiCanyon: Codable {
    internal enum CodingKeys: String, CodingKey {
        case holder = "printouts"
        case pageUrlString = "fullurl"
        case fullName = "fulltext"
    }
    
    let holder: RopewikiHolder
    let pageUrlString: String
    let fullName: String
}

struct RopewikiHolder: Codable {
    internal enum CodingKeys: String, CodingKey {
        case coordinates = "Has coordinates"
        case summary = "Has summary" // "4.9*  4B V R (<i>v5a2&nbsp;V</i>) 12h-2d 10.5mi 25r 290ft"
        case bannerImageUrlString = "Has banner image file" // url
        case kmlFileUrlString = "Has KML file"
        case requiresPermitsRaw = "Requires permits"
        case quality = "Has total Rating"
        case numberOfVisits = "Has total counter"
        case time = "Has info typical time"
        case hikeLength = "Has length of hike"
        case length = "Has length"
        case numberRappels = "Has info rappels"
        case longestRappel = "Has longest rappel"
        case hasConditionSummaryHTML = "Has condition summary"
        case vehicleRaw = "Has vehicle type"
        case shuttle = "Has shuttle length"
        case bestSeasons = "Has best season parsed" // "...,..X,XXX,XXX"
        case pageId = "Has pageid"
    }
    let coordinates: [RopewikiCoordinate]
    let summary: [String]
    let bannerImageUrlString: [String]
    let kmlFileUrlString: [String]
    let requiresPermitsRaw: [String]
    let quality: [Double]?
    let numberOfVisits: [Int]
    let time: [String]
    let hikeLength: [RopewikiUnitValue]
    let length: [RopewikiUnitValue]
    let numberRappels: [String]
    let longestRappel: [RopewikiUnitValue]
    let hasConditionSummaryHTML: [String]
    let vehicleRaw: [String]
    let shuttle: [RopewikiUnitValue]
    let bestSeasons: [RopewikiSeasons]
    let pageId: [String]
}

struct RopewikiCoordinate: Codable {
    internal enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
    
    let latitude: Double
    let longitude: Double
}

struct RopewikiUnitValue: Codable {
    let value: Double
    let unit: String
}

struct RopewikiSeasons: Codable {
    let fulltext: String
}
