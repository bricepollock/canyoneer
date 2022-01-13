//
//  NOAAData.swift
//  whereToClimb
//
//  Created by Brice Pollock on 3/2/19.
//  Copyright © 2019 Brice Pollock. All rights reserved.
//

import Foundation

struct NOAAData {
    struct Point {
        let zone: String
        let gridX: Int
        let gridY: Int
        let weatherOfficeID: String
        
        let forcastURL: URL
        let forcastHourlyURL: URL
        let forcastGridURL: URL
        let stationURL: URL
    }
    
    
    struct PointForecast {
        let updatedTime: String
        let elevation: Double // meters
        let periods: [PeriodSummary]
        
        struct PeriodSummary {
            let date: Date
            let isDay: Bool
            let temperature: Int // degree F
            let windSpeed: Int // mph
            let windBearing: Direction
            let shortForecast: String
            let detailForecast: String
        }
        
    }
    
    struct GridForecast {
        let elevation: Int // meters
        let temperature: [ValueStamp] // semi-hourly, degree C
        let maxTemp: [ValueStamp] // daily, degree C
        let minTemp: [ValueStamp] // daily, degree C


        let windDirection: [ValueStamp] // three-hours,  [0-360] degree
        let windSpeed: [ValueStamp] // three-hours,  m/s
        let precipitation: [ValueStamp] // six-hours, [0-100]%
        let rainQuantity: [ValueStamp] // six-hours, mm
        
        // MARK - We don't use any of these
//        let dewpoint: [ValueStamp] // semi-hourly, degree C
//        let relativeHumidity: [ValueStamp] // hourly, [0-100]%
//        let apparentTemperature: [ValueStamp] // unknown-optional, degree c
//        let heatIndex: [ValueStamp] // unknown-optional, degree c
//        let windChill: [ValueStamp] // unknown-optional, degree c
//        let skyCover: [ValueStamp] // six-hours, [0-100]%
//        let gusting: [ValueStamp] // three-hours (variable),  m/s
//        let weather: [Summary] // random, almost daily
//        let hazards: [String] // unknown-optional, unknown
//        let iceAccumulation: [ValueStamp] // unknown-optional, mm
//        let snow: [ValueStamp] // six-hours, mm
//        let snowLine: [ValueStamp] // six-hours, meter
//        //let ceilingHeight?
//        let visibility: [String] // unknown-optional, unknown
//        let transportWindSpeed: [ValueStamp] // three-hours,  m/s
//        let transportWindDirection: [ValueStamp] // three-hours,  [0-360] degree
//        let mixingHeight: [ValueStamp] // hourly, meters
//        //let hainesIndex?
//        let lightningActivityLevel: [ValueStamp] // random, unknown
//        let twentyFootWindSpeed: [ValueStamp] // three-hours (variable),  m/s
//        let twentyFootWindDirection: [ValueStamp] // three-hours,  [0-360] degree
//
//        let waveHeight: [ValueStamp] // m
//        let wavePeriod: [ValueStamp] // sec
//        let primarySwellHeight: [ValueStamp] // m
//        let primarySwellDirection: [ValueStamp] //[0-360] degree
//        let secondarySwellHeight: [ValueStamp] // m
//        let secondarySwellDirection: [ValueStamp] // [0-360] degree
//        let wavePeriod2: [ValueStamp] // sec
//        let windWaveHeight: [ValueStamp] // m
        
        // MARK - Don't know how to handle these
        // dispersionIndex
        // pressure
        // probabilityOfTropicalStormWinds
        // probabilityOfHurricaneWinds
        // potentialOf15mphWinds
        // potentialOf25mphWinds
        // potentialOf35mphWinds
        // potentialOf45mphWinds
        // potentialOf20mphWindGusts
        // potentialOf30mphWindGusts
        // potentialOf40mphWindGusts
        // potentialOf50mphWindGusts
        // potentialOf60mphWindGusts
        // grasslandFireDangerIndex
        // probabilityOfThunder
        // davisStabilityIndex
        // atmosphericDispersionIndex
        // lowVisibilityOccurrenceRiskIndex
        // stability
        // redFlagThreatIndex
        
        struct Summary {
            let coverage: String? // null, slight_chance, chance, likely, definite
            let weather: String? // null, rain, rain_showers
            let intensity: String? // null, light, heavy
            let visibility: String? // null
            let attributes: String? // null
        }
    }
    
    struct ValueStamp {
        let value: Double
        let time: String
        let date: Date?
    }
}
