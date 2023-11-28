//
//  NOAASerializer.swift
//  whereToClimb
//
//  Created by Brice Pollock on 3/2/19.
//  Copyright © 2019 Brice Pollock. All rights reserved.
//

import Foundation

struct NOAASerializer {
    
    let dateFormatter: DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    }
    
    // point forecast
    func pointForecast(json: NSDictionary) throws -> NOAAData.PointForecast {
        guard let forcastProperties = json["properties"] as? NSDictionary,
            let updatedTime = forcastProperties["updated"] as? String, // iso
            let elevationDetails = forcastProperties["elevation"] as? NSDictionary,
            let elevation = elevationDetails["value"] as? Double, // meter
            let periodsRaw = forcastProperties["periods"] as? NSArray else {
                Global.logger.debug("unable to create point forcast")
                throw RequestError.serialization
        }
        
        return NOAAData.PointForecast(
            updatedTime: updatedTime,
            elevation: Double(elevation) ,
            periods: try periodsRaw.compactMap { try periodForecast(json: (($0 as? NSDictionary) ?? [:])) }
        )
    }
    
    func gridForecast(json: NSDictionary) throws -> NOAAData.GridForecast {
        guard let properties = json["properties"] as? NSDictionary,
            let _ = properties["updateTime"] as? String else {
                Global.logger.debug("unable to decode grid forcast - top")
                throw RequestError.serialization
        }
        guard let elevationDetails = properties["elevation"] as? NSDictionary,
            let elevation = elevationDetails["value"] as? Double,
            let temperatureDetails = properties["temperature"] as? NSDictionary,
            let temperatureValues = temperatureDetails["values"] as? NSArray,
            let dewpointDetails = properties["dewpoint"] as? NSDictionary,
            let _ = dewpointDetails["values"] as? NSArray,
            let maxTemperatureDetails = properties["maxTemperature"] as? NSDictionary,
            let maxTemperatureValues = maxTemperatureDetails["values"] as? NSArray,
            let minTemperatureDetails = properties["minTemperature"] as? NSDictionary,
            let minTemperatureValues = minTemperatureDetails["values"] as? NSArray,
            let relativeHumidityDetails = properties["relativeHumidity"] as? NSDictionary,
            let _ = relativeHumidityDetails["values"] as? NSArray,
            let apparentTemperatureDetails = properties["apparentTemperature"] as? NSDictionary,
            let _ = apparentTemperatureDetails["values"] as? NSArray,
            let heatIndexDetails = properties["heatIndex"] as? NSDictionary,
            let _ = heatIndexDetails["values"] as? NSArray,
            let windChillDetails = properties["windChill"] as? NSDictionary,
            let _ = windChillDetails["values"] as? NSArray else {
                Global.logger.debug("unable to decode grid forcast - temp")
                throw RequestError.serialization
        }
        guard let skyCoverDetails = properties["skyCover"] as? NSDictionary,
            let _ = skyCoverDetails["values"] as? NSArray,
            let windDirectionDetails = properties["windDirection"] as? NSDictionary,
            let windDirectionValues = windDirectionDetails["values"] as? NSArray,
            let windSpeedDetails = properties["windSpeed"] as? NSDictionary,
            let windSpeedValues = windSpeedDetails["values"] as? NSArray,
            let windGustDetails = properties["windGust"] as? NSDictionary,
            let _ = windGustDetails["values"] as? NSArray else {
                Global.logger.debug("unable to decode grid forcast - wind")
                throw RequestError.serialization
        }
        guard let weatherDetails = properties["weather"] as? NSDictionary,
            let _ = weatherDetails["values"] as? NSArray,
            let hazardsDetails = properties["hazards"] as? NSDictionary,
            let _ = hazardsDetails["values"] as? NSArray,
            let probabilityOfPrecipitationDetails = properties["probabilityOfPrecipitation"] as? NSDictionary,
            let probabilityOfPrecipitationValues = probabilityOfPrecipitationDetails["values"] as? NSArray,
            let quantitativePrecipitationDetails = properties["quantitativePrecipitation"] as? NSDictionary,
            let quantitativePrecipitationValues = quantitativePrecipitationDetails["values"] as? NSArray,
            let iceAccumulationDetails = properties["iceAccumulation"] as? NSDictionary,
            let _ = iceAccumulationDetails["values"] as? NSArray,
            let snowfallAmountDetails = properties["snowfallAmount"] as? NSDictionary,
            let _ = snowfallAmountDetails["values"] as? NSArray,
            let snowLevelDetails = properties["snowLevel"] as? NSDictionary,
            let _ = snowLevelDetails["values"] as? NSArray,
            let visibilityDetails = properties["visibility"] as? NSDictionary,
            let _ = visibilityDetails["values"] as? NSArray else {
                Global.logger.debug("unable to decode grid forcast - precip")
                throw RequestError.serialization
        }
        guard let transportWindSpeedDetails = properties["transportWindSpeed"] as? NSDictionary,
            let _ = transportWindSpeedDetails["values"] as? NSArray,
            let transportWindDirectionDetails = properties["transportWindDirection"] as? NSDictionary,
            let _ = transportWindDirectionDetails["values"] as? NSArray,
            let twentyFootWindSpeedDetails = properties["twentyFootWindSpeed"] as? NSDictionary,
            let _ = twentyFootWindSpeedDetails["values"] as? NSArray,
            let twentyFootWindDirectionDetails = properties["twentyFootWindDirection"] as? NSDictionary,
            let _ = twentyFootWindDirectionDetails["values"] as? NSArray,
            let mixingHeightDetails = properties["mixingHeight"] as? NSDictionary,
            let _ = mixingHeightDetails["values"] as? NSArray,
            let lightningActivityLevelDetails = properties["lightningActivityLevel"] as? NSDictionary,
            let _ = lightningActivityLevelDetails["values"] as? NSArray else {
                Global.logger.debug("unable to decode grid forcast - detail wind")
                throw RequestError.serialization
        }
        guard let waveHeightDetails = properties["waveHeight"] as? NSDictionary,
            let _ = waveHeightDetails["values"] as? NSArray,
            let wavePeriodDetails = properties["wavePeriod"] as? NSDictionary,
            let _ = wavePeriodDetails["values"] as? NSArray,
            let primarySwellHeightDetails = properties["primarySwellHeight"] as? NSDictionary,
            let _ = primarySwellHeightDetails["values"] as? NSArray,
            let primarySwellDirectionDetails = properties["primarySwellDirection"] as? NSDictionary,
            let _ = primarySwellDirectionDetails["values"] as? NSArray,
            let secondarySwellHeightDetails = properties["secondarySwellHeight"] as? NSDictionary,
            let _ = secondarySwellHeightDetails["values"] as? NSArray,
            let secondarySwellDirectionDetails = properties["secondarySwellDirection"] as? NSDictionary,
            let _ = secondarySwellDirectionDetails["values"] as? NSArray,
            let wavePeriod2Details = properties["wavePeriod2"] as? NSDictionary,
            let _ = wavePeriod2Details["values"] as? NSArray,
            let windWaveHeightDetails = properties["windWaveHeight"] as? NSDictionary,
            let _ = windWaveHeightDetails["values"] as? NSArray else {
                Global.logger.debug("unable to decode grid forcast - wave")
                throw RequestError.serialization
        }
        
        return NOAAData.GridForecast(
            elevation: Int(elevation),
            temperature: try temperatureValues.compactMap { try valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
            maxTemp: try maxTemperatureValues.compactMap { try valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
            minTemp: try minTemperatureValues.compactMap { try valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
            windDirection: try windDirectionValues.compactMap { try valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
            windSpeed: try windSpeedValues.compactMap { try valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
            precipitation: try probabilityOfPrecipitationValues.compactMap { try valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
            rainQuantity: try quantitativePrecipitationValues.compactMap { try valueStamp(json: ($0 as? NSDictionary) ?? [:]) }
        )
        
//        return NOAAData.GridForecast(
//            elevation: Int(elevation),
//            temperature: temperatureValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            dewpoint: dewpointValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            maxTemp: maxTemperatureValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            minTemp: minTemperatureValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            relativeHumidity: relativeHumidityValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            apparentTemperature: apparentTemperatureValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            heatIndex: heatIndexValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            windChill: windChillValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            skyCover: skyCoverValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            windDirection: windDirectionValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            windSpeed: windSpeedValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            gusting: windGustValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            weather: weatherValues.compactMap { gridSummaryPoint(json: ($0 as? NSDictionary) ?? [:]) },
//            hazards: hazards.compactMap { $0 as? String },
//            precipitation: probabilityOfPrecipitationValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            rainQuantity: quantitativePrecipitationValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            iceAccumulation: iceAccumulationValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            snow: snowfallAmountValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            snowLine: snowLevelValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            visibility: visibility.compactMap { $0 as? String },
//            transportWindSpeed: transportWindSpeedValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            transportWindDirection: transportWindDirectionValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            mixingHeight: mixingHeightValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            lightningActivityLevel: lightningActivityLevelValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            twentyFootWindSpeed: twentyFootWindSpeedValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            twentyFootWindDirection: twentyFootWindDirectionValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            waveHeight: waveHeightValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            wavePeriod: wavePeriodValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            primarySwellHeight: primarySwellHeightValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            primarySwellDirection: primarySwellDirectionValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            secondarySwellHeight: secondarySwellHeightValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            secondarySwellDirection: secondarySwellDirectionValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            wavePeriod2: wavePeriod2Values.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) },
//            windWaveHeight: windWaveHeightValues.compactMap { valueStamp(json: ($0 as? NSDictionary) ?? [:]) }
//        )
    }
    
    func valueStamp(json: NSDictionary) throws -> NOAAData.ValueStamp {
        guard let time = json["validTime"] as? String, let value = json["value"] as? Double else {
            Global.logger.debug("unable to decode value stamp")
            throw RequestError.serialization
        }
        
        return try NOAAData.ValueStamp(value: value, time: time, date: isoFormatToDate(time))
    }
    
    // "2019-03-02T10:00:00+00:00/PT2H"
    func isoFormatToDate(_ string: String) throws -> Date {
        let splitString = string.split(separator: "/")
        // First two letters are the timezone, number indicates how often it updates
        let timeZoneRaw = String(splitString[1])
        let timeZone = String(timeZoneRaw[..<timeZoneRaw.index(timeZoneRaw.startIndex, offsetBy: 2)])
        dateFormatter.timeZone = TimeZone(abbreviation: timeZone)
        guard let date = dateFormatter.date(from: String(splitString[0].split(separator: "+")[0])) else {
            throw RequestError.serialization
        }
        return date
    }
    
    func gridSummaryPoint(json: NSDictionary) throws -> NOAAData.GridForecast.Summary {
        guard let valueList = json["value"] as? NSArray,
            let value = valueList.firstObject as? NSDictionary else {
                Global.logger.debug("unable to decode grid summary")
                throw RequestError.serialization
        }
        return NOAAData.GridForecast.Summary(
            coverage: value["coverage"] as? String,
            weather: value["weather"] as? String,
            intensity: value["intensity"] as? String,
            visibility: value["visibility"] as? String,
            attributes: value["attributes"] as? String
        )
    }
    
    // the period forecast has elevation as well
    func periodForecast(json: NSDictionary) throws -> NOAAData.PointForecast.PeriodSummary {
        guard let dateString = json["startTime"] as? String, //need to get from iso date
            let isDay: Bool = json["isDaytime"] as? Bool,
            let temperature: Int = json["temperature"] as? Int, // degree F
            let windSpeedString = json["windSpeed"] as? String,
            let windDirectionString = json["windDirection"] as? String,
            let shortForecast = json["shortForecast"] as? String,
            let forecastString = json["detailedForecast"] as? String else {
                Global.logger.debug("unable to create period summary")
                throw RequestError.serialization
        }
        
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        guard let bearing = Direction.direction(from: windDirectionString),
            // should probably adjust to the highest value...
            let windSpeedValue = windSpeedString.split(separator: " ").first, // either format "14 mph" or "1 to 10 mph"
            let windSpeed = Int(String(windSpeedValue)),
            let date = formatter.date(from: dateString) else {
                Global.logger.debug("Unable to compute some derived data")
                throw RequestError.serialization
        }
        
        
        return NOAAData.PointForecast.PeriodSummary(
            date: date,
            isDay: isDay,
            temperature: temperature,
            windSpeed: windSpeed,
            windBearing: bearing,
            shortForecast: shortForecast,
            detailForecast: forecastString)
    }
    
    // point
    // can use this to get all other requests
    func pointResponse(json: NSDictionary) throws -> NOAAData.Point {
        guard let pointProperties = json["properties"] as? NSDictionary,
            let zoneURL = pointProperties["forecastZone"] as? String,
            let gridX = pointProperties["gridX"] as? Int,
            let gridY = pointProperties["gridY"] as? Int,
            let weatherOfficeID = pointProperties["cwa"] as? String else {
                Global.logger.debug("unable to create noaa point")
                throw RequestError.serialization
        }
        
        guard let zone = URL(string: zoneURL)?.lastPathComponent else {
                Global.logger.debug("Unable to compute some derived data for noaa point")
                throw RequestError.serialization
        }
        
        guard let forcastURLRaw = pointProperties["forecast"] as? String,
            let forcastURL = URL(string: forcastURLRaw),
            let forcastHourlyURLRaw = pointProperties["forecastHourly"] as? String,
            let forcastHourlyURL = URL(string: forcastHourlyURLRaw),
            let forcastGridURLRaw = pointProperties["forecastGridData"] as? String,
            let forcastGridURL = URL(string: forcastGridURLRaw),
            let stationURLRaw = pointProperties["observationStations"] as? String,
            let stationURL = URL(string: stationURLRaw) else {
                Global.logger.debug("didn't have some url NOAA data")
                throw RequestError.serialization
        }
        
        return NOAAData.Point(zone: zone,
                              gridX: gridX,
                              gridY: gridY,
                              weatherOfficeID: weatherOfficeID,
                              forcastURL: forcastURL,
                              forcastHourlyURL: forcastHourlyURL,
                              forcastGridURL: forcastGridURL,
                              stationURL: stationURL
        )
    }
}
