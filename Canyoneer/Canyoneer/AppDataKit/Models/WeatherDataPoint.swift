//
//  WeatherDataPoint.swift
//  Pack List
//
//  Created by Personal on 1/19/16.
//  Copyright © 2016 Backcountry Studios. All rights reserved.
//

import Foundation

enum WeatherIconType: String {
    case unknown = ""
    case clearDay = "clear-day"
    case clearNight = "clear-night"
    case rain = "rain"
    case snow = "snow"
    case sleet = "sleet"
    case wind = "wind"
    case fog = "fog"
    case cloudy = "cloudy"
    case partlyCloudyDay = "partly-cloudy-day"
    case partlyCloudyNight = "partly-cloudy-night"
    case hail = "hail"
    case thunderstorm = "thunderstorm"
    case tornado = "tornado"
}

enum MoonPhase: Double {
    case newMoon = 0
    case quarter = 0.25
    case fullMoon = 0.5
    case lastQuarter = 0.75
    
    func toString() -> String {
        switch (self) {
        case .newMoon: return "New Moon"
        case .quarter: return "Quarter Moon"
        case .fullMoon: return "Full Moon"
        case .lastQuarter: return "Last Quarter Moon"
        }
    }
    
    static func fromRaw(raw: Double) -> MoonPhase {
        let tolerance = 0.125
        
        if (raw == MoonPhase.newMoon.rawValue) {
            return MoonPhase.newMoon
        } else if (raw < MoonPhase.newMoon.rawValue + tolerance) {
            return MoonPhase.newMoon
        } else if (raw < MoonPhase.quarter.rawValue + tolerance) {
            return MoonPhase.quarter
        } else if (raw < MoonPhase.fullMoon.rawValue + tolerance) {
            return MoonPhase.fullMoon
        } else  {
            return MoonPhase.lastQuarter
        }
    }
}

// inch / hr
enum PrecipIntensity: Double {
    case none = 0.0
    case veryLight = 0.002
    case light = 0.017
    case moderate = 0.1
    case heavy = 0.4
    
    func toString() -> String {
        switch (self) {
        case .none: return "None"
        case .veryLight: return "Very Light"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .heavy: return "Heavy"
        }
    }
    
    static func fromRaw(raw: Double) -> PrecipIntensity {
        let moderateTolerance = PrecipIntensity.light.rawValue + 0.5 * (PrecipIntensity.moderate.rawValue - PrecipIntensity.light.rawValue)
        let heavyTolerance = PrecipIntensity.moderate.rawValue + 0.5 * (PrecipIntensity.heavy.rawValue - PrecipIntensity.moderate.rawValue)
        
        if (raw == PrecipIntensity.none.rawValue) {
            return PrecipIntensity.none
        } else if (raw < PrecipIntensity.veryLight.rawValue) {
            return PrecipIntensity.veryLight
        } else if (raw < PrecipIntensity.light.rawValue) {
            return PrecipIntensity.veryLight
        } else if (raw < moderateTolerance) {
            return PrecipIntensity.light
        } else if (raw < heavyTolerance) {
            return PrecipIntensity.moderate
        } else {
            return PrecipIntensity.heavy
        }
    }
}

enum CloudCover: Double {
    case clear = 0.0
    case scattered = 0.4
    case broken = 0.75
    case overcast = 1
    
    func toString() -> String {
        switch (self) {
        case .clear: return "Clear"
        case .scattered: return "Scattered"
        case .broken: return "Broken"
        case .overcast: return "Overcast"
        }
    }
    
    static func fromRaw(raw: Double) -> CloudCover {
        if (raw == CloudCover.clear.rawValue) {
            return CloudCover.clear
        } else if (raw < CloudCover.scattered.rawValue) {
            return CloudCover.scattered
        } else if (raw < CloudCover.broken.rawValue) {
            return CloudCover.broken
        } else {
            return CloudCover.overcast
        }
    }
}

enum Direction: String {
    case north = "N"
    case northEast = "NE"
    case east = "E"
    case southEast = "SE"
    case south = "S"
    case southWest = "SW"
    case west = "W"
    case northWest = "NW"
    
    static func allValues() -> [Direction] {
        return [.north, .northEast, .east, .southEast, .south, .southWest, .west, .northWest]
    }
    
    func asBearing() -> Double {
        let distanceBetweenDirections = 0.25
        let halfDistanceBetweenDirections = 0.5*distanceBetweenDirections
        
        let north: Double = 0
        let northEast = north + halfDistanceBetweenDirections
        let east = north + distanceBetweenDirections
        let southEast = east + halfDistanceBetweenDirections
        let south = east + distanceBetweenDirections
        let southWest = south + halfDistanceBetweenDirections
        let west = south + distanceBetweenDirections
        let northWest = west + halfDistanceBetweenDirections
        
        switch (self) {
        case .north:
            return north
        case .northEast:
            return northEast
        case .east:
            return east
        case .southEast:
            return southEast
        case .south:
            return south
        case .southWest:
            return southWest
        case .west:
            return west
        case .northWest:
            return northWest
        }
    }
    
    static func direction(from bearing: Double) -> Direction {
        let directionalityTolerance = 0.625
        for direction in Direction.allValues() {
            if (abs(bearing - direction.asBearing()) <= directionalityTolerance) {
                return direction
            }
        }
            
        return .north
    }
    
    static func direction(from fuzzyString: String) -> Direction? {
        if fuzzyString.count < 3 {
            return Direction(rawValue: fuzzyString)
        }
        
        // take last two
        return Direction(rawValue: String(fuzzyString[fuzzyString.index(fuzzyString.endIndex, offsetBy: -2)...]))
    }
}

class WeatherDataAlert: NSObject, NSCoding {
    let title: String?
    let expirationTime: Date?
    let detail: String?
    let URI: String? // An HTTP(S) URI that contains detailed information about the alert.
    
    init(
        title: String?,
        expirationTime: Date?,
        detail: String?,
        URI: String?) {
        self.title = title
        self.expirationTime = expirationTime
        self.detail = detail
        self.URI = URI
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as? String
        expirationTime = aDecoder.decodeObject(forKey: "expirationTime") as? Date
        detail = aDecoder.decodeObject(forKey: "detail") as? String
        URI = aDecoder.decodeObject(forKey: "URI") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        if let title = title { aCoder.encode(title, forKey: "title") }
        if let expirationTime = expirationTime { aCoder.encode(expirationTime, forKey: "expirationTime") }
        if let detail = detail { aCoder.encode(detail, forKey: "detail") }
        if let URI = URI { aCoder.encode(URI, forKey: "URI") }
    }
}

class WeatherDataPoint: NSObject, NSCoding {
    let time: Date?
    let iconType: WeatherIconType?
    let summary: String? // A human-readable text summary of this data point.
    let sunrise: Date?
    let sunset: Date?
    let moonPhase: MoonPhase?
    let precipProbability: Double? // [0-1]
    let precipIntensity: PrecipIntensity?
    let cloudCover: CloudCover?
    let windSpeed: Double? //mph
    let windBearing: Double? // zero is north, going clockwise
    let temperature: Double? // temperature at given time, not available on daily metric (F)
    let temperatureMax: Double? // F
    let temperatureMin: Double? // F
    let temperatureMaxTime: Date?
    let temperatureMinTime: Date?
    let visibility: Double? // miles visible, capped at 10 miles
    let pressure: Double? // millibars
    let alerts: [WeatherDataAlert]
    
    init(
        time: Date?,
        iconType: WeatherIconType?,
        summary: String?,
        sunrise: Date?,
        sunset: Date?,
        moonPhase: MoonPhase?,
        precipProbability: Double?,
        precipIntensity: PrecipIntensity?,
        cloudCover: CloudCover?,
        windSpeed: Double?,
        windBearing: Double?,
        temperature: Double?,
        temperatureMax: Double?,
        temperatureMin: Double?,
        temperatureMaxTime: Date?,
        temperatureMinTime: Date?,
        visibility: Double?,
        pressure: Double?,
        alerts: [WeatherDataAlert]) {
        self.time = time
        self.iconType = iconType
        self.summary = summary
        self.sunrise = sunrise
        self.sunset = sunset
        self.moonPhase = moonPhase
        self.precipProbability = precipProbability
        self.precipIntensity = precipIntensity
        self.cloudCover = cloudCover
        self.windSpeed = windSpeed
        self.windBearing = windBearing
        self.temperature = temperature
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.temperatureMaxTime = temperatureMaxTime
        self.temperatureMinTime = temperatureMinTime
        self.visibility = visibility
        self.pressure = pressure
        self.alerts = alerts
    }
    
    required init?(coder aDecoder: NSCoder) {
        time = aDecoder.decodeObject(forKey: "time") as? Date
        if let value = aDecoder.decodeObject(forKey: "iconType") as? String {
            iconType = WeatherIconType(rawValue: value)
        } else {
            iconType = nil
        }
        summary = aDecoder.decodeObject(forKey: "summary") as? String
        sunrise = aDecoder.decodeObject(forKey: "sunrise") as? Date
        sunset = aDecoder.decodeObject(forKey: "sunset") as? Date
        moonPhase = MoonPhase.fromRaw(raw: aDecoder.decodeDouble(forKey: "moonPhase"))
        precipProbability = aDecoder.decodeDouble(forKey: "precipProbability")
        precipIntensity = PrecipIntensity.fromRaw(raw: aDecoder.decodeDouble(forKey: "precipIntensity"))
        cloudCover = CloudCover.fromRaw(raw: aDecoder.decodeDouble(forKey: "cloudCover"))
        windSpeed = aDecoder.decodeDouble(forKey: "windSpeed")
        windBearing = aDecoder.decodeDouble(forKey: "windBearing")
        temperature = aDecoder.decodeDouble(forKey: "temperature")
        temperatureMax = aDecoder.decodeDouble(forKey: "temperatureMax")
        temperatureMin = aDecoder.decodeDouble(forKey: "temperatureMin")
        temperatureMaxTime = aDecoder.decodeObject(forKey: "temperatureMaxTime") as? Date
        temperatureMinTime = aDecoder.decodeObject(forKey: "temperatureMinTime") as? Date
        visibility = aDecoder.decodeDouble(forKey: "visibility")
        pressure = aDecoder.decodeDouble(forKey: "pressure")
        alerts = aDecoder.decodeObject(forKey: "alerts") as? [WeatherDataAlert] ?? []
    }
    
    func encode(with aCoder: NSCoder) {
        if let time = time { aCoder.encode(time, forKey: "time") }
        if let iconType = iconType { aCoder.encode(iconType.rawValue, forKey: "iconType") }
        if let summary = summary { aCoder.encode(summary, forKey: "summary") }
        if let sunrise = sunrise { aCoder.encode(sunrise, forKey: "sunrise") }
        if let sunset = sunset { aCoder.encode(sunset, forKey: "sunset") }
        if let moonPhase = moonPhase { aCoder.encode(moonPhase.rawValue, forKey: "moonPhase") }
        if let precipProbability = precipProbability { aCoder.encode(precipProbability, forKey: "precipProbability") }
        if let precipIntensity = precipIntensity { aCoder.encode(precipIntensity.rawValue, forKey: "precipIntensity") }
        if let cloudCover = cloudCover { aCoder.encode(cloudCover.rawValue, forKey: "cloudCover") }
        if let windSpeed = windSpeed { aCoder.encode(windSpeed, forKey: "windSpeed") }
        if let windBearing = windBearing { aCoder.encode(windBearing, forKey: "windBearing") }
        if let temperature = temperature { aCoder.encode(temperature, forKey: "temperature") }
        if let temperatureMax = temperatureMax { aCoder.encode(temperatureMax, forKey: "temperatureMax") }
        if let temperatureMin = temperatureMin { aCoder.encode(temperatureMin, forKey: "temperatureMin") }
        if let temperatureMaxTime = temperatureMaxTime { aCoder.encode(temperatureMaxTime, forKey: "temperatureMaxTime") }
        if let temperatureMinTime = temperatureMinTime { aCoder.encode(temperatureMinTime, forKey: "temperatureMinTime") }
        if let visibility = visibility { aCoder.encode(visibility, forKey: "visibility") }
        if let pressure = pressure { aCoder.encode(pressure, forKey: "pressure") }
        aCoder.encode(alerts, forKey: "alerts")
    }
}
