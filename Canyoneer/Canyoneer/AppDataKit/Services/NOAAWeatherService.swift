//
//  NOAAWeatherService.swift
//  whereToClimb
//
//  Created by Brice Pollock on 12/10/18.
//  Copyright © 2018 Brice Pollock. All rights reserved.
//

import Foundation

// https://forecast-v3.weather.gov/documentation
// https://www.weather.gov/documentation/services-web-api#/default/get_points__point__forecast

enum NOAARequest {
    case point(Double, Double)
    case pointForecast(Double, Double)
    case gridForecast(String, Double, Double)
    
    static let domain = "https://api.weather.gov/"
    
    var urlString: String {
        switch self {
        // https://api.weather.gov/points/37.7748,-122.4541
        case .point(let lat, let long):
            return "\(NOAARequest.domain)/points/\(lat),\(long)"
        // https://api.weather.gov/points/37.7748,-122.4541/forecast
        case .pointForecast(let lat, let long):
            return "\(NOAARequest.point(lat, long).urlString)/forecast"
        // https://api.weather.gov/gridpoints/MTR/86,126
        case .gridForecast(let office, let gridX, let gridY):
            return "\(NOAARequest.domain)/gridpoints/\(office)/\(gridX),\(gridY)"
        }
        // https://api.weather.gov/stations/KMKC/observations
        // gives you precipitationLast6Hours and all sorts of max/min stuff
    }
}

protocol WeatherService {
    func requestCurrentWeatherForLocation(lat: Double, long: Double) async throws -> WeatherDetails
    func requestHistoricalWeatherForLocation(lat: Double, long: Double, date: Date) async throws -> WeatherDetails
}

class NOAAWeatherService: NetworkService, WeatherService {
    
    private let aDayInSeconds: Double = 24*60*60
    
    let weatherSerializer = NOAASerializer()
    init() {
//        let additionalHeaders =  [
//            "Accept": "application/ld+json;version=1"
//        ]
//        super(additionalHeaders: additionalHeaders)
        super.init()
    }
    
    func requestPointForLocation(lat: Double, long: Double) async throws -> NOAAData.Point {
        let endpoint = NOAARequest.point(lat, long)
        guard let url = URL(string: endpoint.urlString) else {
            Global.logger.debug("could not create URL for NOAA points!")
            throw RequestError.badRequest
        }
        
        let response = try await request(url: url)
        return try self.weatherSerializer.pointResponse(json: response.json)
    }
    
    func requestForecastForURL(url: URL) async throws -> NOAAData.PointForecast {
        let response = try await request(url: url)
        return try weatherSerializer.pointForecast(json: response.json)
    }
    
    func requestGridForOffice(officeID: String, lat: Double, long: Double) async throws -> NOAAData.GridForecast {
        let endpoint = NOAARequest.gridForecast(officeID, lat, long)
        guard let url = URL(string: endpoint.urlString) else {
            Global.logger.debug("could not create URL for NOAA forcast!")
            throw RequestError.badRequest
        }
        let response = try await request(url: url)
        return try weatherSerializer.gridForecast(json: response.json)
    }
    
    // TODO: Get the preciptation history from stations info
    // https://api.weather.gov/stations/KMKC/observations
    // gives you precipitationLast6Hours and all sorts of max/min struff
    
    func requestCurrentWeatherForLocation(lat: Double, long: Double) async throws -> WeatherDetails {
        return try await requestHistoricalWeatherForLocation(lat: lat, long: long, date: Date())
    }
    
    func requestHistoricalWeatherForLocation(lat: Double, long: Double, date: Date) async throws -> WeatherDetails {

        // in parallel ask for point and point forecast
        // with result get grid forecast for more detail on 7-day
        
        // abstracting info out of point-forecast
        // night and day temps seems to correlate well enough with max-min temp
        // can probably search the icon for 'rain', 'snow' to show precip
        
        // need some thing for sunrise / sunset
        // https://github.com/ceeK/Solar
        // https://sunrise-sunset.org/api
        // port algorithm: https://stackoverflow.com/questions/2056555/c-sharp-sunrise-sunset-with-latitude-longitude
        
        let coord = Coordinate(latitude: lat, longitude: long)
        let point = try await requestPointForLocation(lat: lat, long: long)
        let forecast = try await requestForecastForURL(url: point.forcastURL)
        let forcastGridResponse = try await self.request(url: point.forcastGridURL)
        
        let gridForecast = try weatherSerializer.gridForecast(json: forcastGridResponse.json)
        return try convertToWeatherResponse(areaCoord: coord, date: date, pointForecast: forecast, gridForecast: gridForecast)
    }
    
    private func convertToWeatherResponse(areaCoord: Coordinate, date: Date, pointForecast: NOAAData.PointForecast, gridForecast: NOAAData.GridForecast) throws -> WeatherDetails {
        var weatherPoints = [WeatherDataPoint]()
        
        for dayIndex in 0..<gridForecast.maxTemp.count {
            guard let date = gridForecast.maxTemp[dayIndex].date else { continue }
            weatherPoints.append( WeatherDataPoint(
                time: date,
                iconType: nil,
                summary: nil,
                sunrise: nil,
                sunset: nil,
                moonPhase: nil,
                precipProbability: averageValue(date: date, values: gridForecast.precipitation) / 100,
                precipIntensity: PrecipIntensity.fromRaw(raw: UnitConverter.mmToInch(averageValue(date: date, values: gridForecast.rainQuantity))),
                cloudCover: nil,
                windSpeed: UnitConverter.msToMph(averageValue(date: date, values: gridForecast.windSpeed)),
                windBearing: averageValue(date: date, values: gridForecast.windDirection),
                temperature: UnitConverter.celciusToF(averageValue(date: date, values: gridForecast.temperature)),
                temperatureMax: UnitConverter.celciusToF(gridForecast.maxTemp[dayIndex].value),
                temperatureMin: UnitConverter.celciusToF(gridForecast.minTemp[dayIndex].value),
                temperatureMaxTime: nil,
                temperatureMinTime: nil,
                visibility: nil,
                pressure: nil,
                alerts: []
                ))
        }
        
        let requested = try weatherForDate(points: weatherPoints, onDate: date)
        let priorDay = date.addingTimeInterval(-aDayInSeconds)
        let nextDay = date.addingTimeInterval(+aDayInSeconds)
        let dayAfter = date.addingTimeInterval(2*aDayInSeconds)
        
        return WeatherDetails(
            areaCoord: areaCoord,
            prior: try? weatherForDate(points: weatherPoints, onDate: priorDay),
            priorDate: priorDay,
            requested: requested,
            requestedDate: date,
            next: try? weatherForDate(points: weatherPoints, onDate: nextDay),
            nextDate: nextDay,
            dayAfter: try? weatherForDate(points: weatherPoints, onDate: dayAfter),
            dayAfterDate: dayAfter
        )
    }
    
    func weatherForDate(points: [WeatherDataPoint], onDate date: Date) throws -> WeatherDataPoint {
        let found = points.filter({
            guard let dayDate = $0.time else { return false }
            return Calendar.current.isDate(date, inSameDayAs: dayDate)
        }).first
        
        guard let found else {
            throw GeneralError.notFound
        }
        return found
    }
    
    func averageValue(date: Date, values: [NOAAData.ValueStamp]) -> Double {
        let valuesInDay = values.filter {
            guard let valueDate = $0.date else { return false }
            return Calendar.current.isDate(date, inSameDayAs: valueDate)
        }
        if valuesInDay.isEmpty {
            return 0
        }
        return valuesInDay.reduce(0) { $0 + $1.value } / Double(valuesInDay.count)
    }
}
