//
//  WeatherDataResponse.swift
//  Pack List
//
//  Created by Personal on 1/19/16.
//  Copyright © 2016 Backcountry Studios. All rights reserved.
//

import Foundation

class WeatherDataResponse: NSObject, NSCoding {
    let areaCoord: Coordinate
    let date: Date
    let current: WeatherDataPoint?
    let daily: [WeatherDataPoint]
    let hourly: [WeatherDataPoint]
    
    init(areaCoord: Coordinate, date: Date, current: WeatherDataPoint?, daily: [WeatherDataPoint], hourly: [WeatherDataPoint]) {
        self.areaCoord = areaCoord
        self.date = date
        self.current = current
        self.daily = daily
        self.hourly = hourly
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let areaCoord = aDecoder.decodeObject(forKey: "areaCoord") as? Coordinate,
            let date = aDecoder.decodeObject(forKey: "date") as? Date
            else { return nil }
        self.areaCoord = areaCoord
        self.date = date
        current = aDecoder.decodeObject(forKey: "current") as? WeatherDataPoint
        daily = aDecoder.decodeObject(forKey: "daily") as? [WeatherDataPoint] ?? []
        hourly = aDecoder.decodeObject(forKey: "hourly") as? [WeatherDataPoint] ?? []
    }
    
    func encode(with aCoder: NSCoder) {
        if let current = current { aCoder.encode(current, forKey: "current") }
        aCoder.encode(areaCoord, forKey: "areaCoord")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(daily, forKey: "daily")
        aCoder.encode(hourly, forKey: "hourly")
    }
}

class WeatherDetails: NSObject, NSCoding {
    let areaCoord: Coordinate
    let prior: WeatherDataPoint?
    let priorDate: Date
    let requested: WeatherDataPoint
    let requestedDate: Date
    let next: WeatherDataPoint?
    let nextDate: Date
    let dayAfter: WeatherDataPoint?
    let dayAfterDate: Date?
    
    init(
        areaCoord: Coordinate,
        prior: WeatherDataPoint?,
        priorDate: Date,
        requested: WeatherDataPoint,
        requestedDate: Date,
        next: WeatherDataPoint?,
        nextDate: Date,
        dayAfter: WeatherDataPoint?,
        dayAfterDate: Date?
        ) {
        self.areaCoord = areaCoord
        self.prior = prior
        self.priorDate = priorDate
        self.requested = requested
        self.requestedDate = requestedDate
        self.next = next
        self.nextDate = nextDate
        self.dayAfter = dayAfter
        self.dayAfterDate = dayAfterDate
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let areaCoord = aDecoder.decodeObject(forKey: "areaCoord") as? Coordinate,
            let priorDate = aDecoder.decodeObject(forKey: "priorDate") as? Date,
            let requested = aDecoder.decodeObject(forKey: "requested") as? WeatherDataPoint,
            let requestedDate = aDecoder.decodeObject(forKey: "requestedDate") as? Date,
            let nextDate = aDecoder.decodeObject(forKey: "nextDate") as? Date
            else { return nil }
        self.areaCoord = areaCoord
        self.prior = aDecoder.decodeObject(forKey: "prior") as? WeatherDataPoint
        self.priorDate = priorDate
        self.requested = requested
        self.requestedDate = requestedDate
        self.next = aDecoder.decodeObject(forKey: "next") as? WeatherDataPoint
        self.nextDate = nextDate
        self.dayAfter = aDecoder.decodeObject(forKey: "dayAfter") as? WeatherDataPoint
        self.dayAfterDate = aDecoder.decodeObject(forKey: "dayAfterDate") as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(areaCoord, forKey: "areaCoord")
        if let prior = self.prior {
            aCoder.encode(prior, forKey: "prior")
        }
        aCoder.encode(priorDate, forKey: "priorDate")
        aCoder.encode(requested, forKey: "requested")
        aCoder.encode(requestedDate, forKey: "requestedDate")
        if let next = self.next {
            aCoder.encode(next, forKey: "next")
        }
        aCoder.encode(nextDate, forKey: "nextDate")
        
        if let dayAfter = dayAfter {
            aCoder.encode(dayAfter, forKey: "dayAfter")
        }
        if let dayAfterDate = dayAfterDate {
            aCoder.encode(dayAfterDate, forKey: "dayAfterDate")
        }
    }
}
