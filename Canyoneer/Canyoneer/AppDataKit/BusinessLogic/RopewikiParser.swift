//
//  RopewikiParser.swift
//  Canyoneer
//
//  Created by Brice Pollock on 2/9/22.
//

import Foundation

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
}
