//
//  RopewikiParser.swift
//  Canyoneer
//
//  Created by Brice Pollock on 2/9/22.
//

import Foundation

struct RopewikiCanyonDetails {
    let quality: Double
    let technical: Int
    let time: String
    let risk: Risk?
    let water: String
}

struct RopewikiParser {
    static func parseTimeOfYear(string: String) -> [Month] {
        guard string.count == 15 else { return [] }
        let seasons = string.split(separator: ",")
        var bestTimes: [Month] = []
        if seasons[0][0] == "X" {
            bestTimes.append(.january)
        }
        if seasons[0][1] == "X" {
            bestTimes.append(.february)
        }
        if seasons[0][2] == "X" {
            bestTimes.append(.march)
        }
        if seasons[1][0] == "X" {
            bestTimes.append(.april)
        }
        if seasons[1][1] == "X" {
            bestTimes.append(.may)
        }
        if seasons[1][2] == "X" {
            bestTimes.append(.june)
        }
        if seasons[2][0] == "X" {
            bestTimes.append(.july)
        }
        if seasons[2][1] == "X" {
            bestTimes.append(.august)
        }
        if seasons[2][2] == "X" {
            bestTimes.append(.september)
        }
        if seasons[3][0] == "X" {
            bestTimes.append(.october)
        }
        if seasons[3][1] == "X" {
            bestTimes.append(.november)
        }
        if seasons[3][2] == "X" {
            bestTimes.append(.december)
        }
        return bestTimes
    }
    
    static func parseBooleanString(_ string: String) -> Bool? {
        if string.lowercased() == "yes" { return true }
        else if string.lowercased() == "no" { return false }
        else { return nil }
    }
    
    static func parseSummary(_ string: String) -> RopewikiCanyonDetails? {
        let timeCharSet = CharacterSet(charactersIn: "IV")
        let waterCharSet = CharacterSet(charactersIn: "ABCD")
        let riskCharacterSet = CharacterSet(charactersIn: "PGRX")
        
        var segments = string.split(separator: " ").map { return String($0) }
        var quality: Double? = nil
        var technical: Int? = nil
        var water: String? = nil
        var time: String? = nil
        var risk: Risk? = nil
        while segments.count > 0 {
            let segment = String(segments.first ?? "")
            if segment.contains("*") {
                quality = Double(String(segment.dropLast()))
            } else if segment.rangeOfCharacter(from: waterCharSet) != nil {
                if segment.count == 2 {
                    technical = Int(segment[0])
                    water = segment[1]
                } else {
                    Global.logger.error("Expected a two-char segment of technical-water, but more than two chars")
                }
            } else if segment.rangeOfCharacter(from: riskCharacterSet) != nil {
                if segment.count <= 2 {
                    risk = Risk(rawValue: segment)
                } else {
                    Global.logger.error("Expectd a 1-2 char risk rating but had more characters than that")
                }
            } else if segment.rangeOfCharacter(from: timeCharSet) != nil {
                if segment.count <= 2 {
                    time = segment
                } else {
                    Global.logger.error("Expectd a 1-2 char technical rating but had more characters than that")
                }
            }
            segments = Array(segments.dropFirst())
        }
        
        guard let quality = quality, let technical = technical, let time = time, let water = water else {
            Global.logger.error("Missing a required property we should have pulled out of the summary. One of the following: \nQuality: \(String(describing: quality))\nTechnical: \(String(describing: technical))\nTime: \(String(describing: time))\nWater: \(String(describing: water))")
            return nil
        }
        return RopewikiCanyonDetails(
            quality: quality,
            technical: technical,
            time: time,
            risk: risk,
            water: water
        )
    }
}
