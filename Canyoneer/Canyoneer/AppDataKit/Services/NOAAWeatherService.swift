//
//  NOAAWeatherService.swift
//  whereToClimb
//
//  Created by Brice Pollock on 12/10/18.
//  Copyright © 2018 Brice Pollock. All rights reserved.
//

import Foundation
import RxSwift

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

class NOAAWeatherService: Service, WeatherService {
    
    private let aDayInSeconds: Double = 24*60*60
    
    let weatherSerializer = NOAASerializer()
    init() {
//        let additionalHeaders =  [
//            "Accept": "application/ld+json;version=1"
//        ]
//        super(additionalHeaders: additionalHeaders)
        super.init()
    }
    
    func requestPointForLocation(lat: Double, long: Double) -> Observable<NOAAData.Point?> {
        let endpoint = NOAARequest.point(lat, long)
        guard let url = URL(string: endpoint.urlString) else {
            Global.logger.debug("could not create URL for NOAA points!")
            return Observable.just(nil)
        }
        return request(url: url).map { [weak self] response in
            guard let json = response.json else { return nil }
            return self?.weatherSerializer.pointResponse(json: json)
        }
    }
    
    func requestForecastForURL(url: URL) -> Observable<NOAAData.PointForecast?> {
        return request(url: url).map { [weak self] response in
            guard let json = response.json else { return nil }
            return self?.weatherSerializer.pointForecast(json: json)
        }
    }
    
    func requestGridForOffice(officeID: String, lat: Double, long: Double) -> Observable<NOAAData.GridForecast?> {
        let endpoint = NOAARequest.gridForecast(officeID, lat, long)
        guard let url = URL(string: endpoint.urlString) else {
            Global.logger.debug("could not create URL for NOAA forcast!")
            return Observable.just(nil)
        }
        return request(url: url).map { [weak self] response in
            guard let json = response.json else { return nil }
            return self?.weatherSerializer.gridForecast(json: json)
        }
    }
    
    // TODO: Get the preciptation history from stations info
    // https://api.weather.gov/stations/KMKC/observations
    // gives you precipitationLast6Hours and all sorts of max/min struff
    
    func requestCurrentWeatherForLocation(lat: Double, long: Double) -> Observable<WeatherDetails?> {
        return requestHistoricalWeatherForLocation(lat: lat, long: long, date: Date())
    }
    
    func requestHistoricalWeatherForLocation(lat: Double, long: Double, date: Date) -> Observable<WeatherDetails?> {

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
        let pointRequest = requestPointForLocation(lat: lat, long: long)
        
        return pointRequest.flatMap { point -> Observable<(NOAAData.Point?, NOAAData.PointForecast?)> in
            guard let forecastPoint = point else {
                return Observable<(NOAAData.Point?, NOAAData.PointForecast?)>.just((nil, nil))
                
            }
            return self.requestForecastForURL(url: forecastPoint.forcastURL).map { forecast in
                return (forecastPoint, forecast)
            }
        }.flatMap { combined -> Observable<WeatherDetails?> in
            let (point, forecast) = combined
            
            guard let foundPoint = point else {
                Global.logger.debug("Failed point or forcast calls")
                return Observable<WeatherDetails?>.just(nil)
            }
            
            return self.request(url: foundPoint.forcastGridURL)
                .map { [weak self] response in
                    guard let json = response.json,
                        let foundForecast = forecast,
                        let gridForecast = self?.weatherSerializer.gridForecast(json: json),
                        let weatherReponse = self?.convertToWeatherResponse(areaCoord: coord, date: date, pointForecast: foundForecast, gridForecast: gridForecast) else {
                            return nil
                    }
                    return weatherReponse
            }
            }.do(onNext: { (response) in
                if (response == nil) {
                    Global.logger.debug("weather failed for \(coord.latitude), \(coord.longitude)")
                }
            })
    }
    
    private func convertToWeatherResponse(areaCoord: Coordinate, date: Date, pointForecast: NOAAData.PointForecast, gridForecast: NOAAData.GridForecast) -> WeatherDetails? {
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
        
        guard let requested = weatherForDate(points: weatherPoints, onDate: date) else {
            return nil
        }
        
        let priorDay = date.addingTimeInterval(-aDayInSeconds)
        let nextDay = date.addingTimeInterval(+aDayInSeconds)
        let dayAfter = date.addingTimeInterval(2*aDayInSeconds)
        
        return WeatherDetails(
            areaCoord: areaCoord,
            prior: weatherForDate(points: weatherPoints, onDate: priorDay),
            priorDate: priorDay,
            requested: requested,
            requestedDate: date,
            next: weatherForDate(points: weatherPoints, onDate: nextDay),
            nextDate: nextDay,
            dayAfter: weatherForDate(points: weatherPoints, onDate: dayAfter),
            dayAfterDate: dayAfter
        )
    }
    
    func weatherForDate(points: [WeatherDataPoint], onDate date: Date) -> WeatherDataPoint? {
        return points.filter {
            guard let dayDate = $0.time else { return false }
            return Calendar.current.isDate(date, inSameDayAs: dayDate)
        }.first
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
