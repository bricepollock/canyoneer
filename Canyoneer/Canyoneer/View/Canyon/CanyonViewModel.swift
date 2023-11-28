//
//  CanyonViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import Combine

struct DayWeatherDetails {
    let temp: String
    let precip: String
    let dayOfWeek: String
}

struct ThreeDayForecast {
    let today: DayWeatherDetails?
    let tomorrow: DayWeatherDetails?
    let dayAfterTomorrow: DayWeatherDetails?
    let sunsetDetails: String
}

extension WeatherDataPoint {
    enum Strings {
        static func temp(max: Double, min: Double) -> String {
            return "\(Int(min)) - \(Int(max)) °F"
        }
        static func precip(chance: Double) -> String {
            let percentage = chance * 100
            return "\(String(Int(percentage)))% Moisture"
        }
    }
    
    var dayDetails: DayWeatherDetails? {
        guard let max = self.temperatureMax, let min = self.temperatureMin, let precip = self.precipProbability, let date = self.time else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeek = dateFormatter.string(from: date).capitalized
        
        return DayWeatherDetails(
            temp: Strings.temp(max: max, min: min),
            precip: Strings.precip(chance: precip),
            dayOfWeek: dayOfWeek
        )
    }
}

@MainActor
class CanyonViewModel {
    enum Strings {
        static func sunsetTimes(sunset: Date, sunrise: Date) -> String {
            let sunsetTime = DateFormatter.localizedString(
                from: sunset,
                dateStyle: .none,
                timeStyle: .short
            )
            let sunriseTime = DateFormatter.localizedString(
                from: sunrise,
                dateStyle: .none,
                timeStyle: .short
            )
            let time = sunset.timeIntervalSince(sunrise) / 60 / 60
            let hours = Int(time.rounded(.toNearestOrEven))
            return "Daylight: \(sunriseTime) - \(sunsetTime) (\(hours) hours)"
        }
    }
    
    @Published public var canyon: Canyon?
    @Published public var isFavorite: Bool?
    @Published public var forecast: ThreeDayForecast?
    @Published public var shareGPXFile: URL?
    
    // state
    public let gpxLoader = LoadingComponent()
    private let canyonId: String
    
    // objects
    private let service: RopeWikiServiceInterface
    private let favoriteService = FavoriteService()
    private let weatherService: WeatherService = NOAAWeatherService()
    private let gpxService = GPXService()
    private let solarService = SolarService()
    
    init(canyonId: String, service: RopeWikiServiceInterface = RopeWikiService()) {
        self.canyonId = canyonId
        self.service = service
    }
    
    // MARK: Actions
    public func refresh() async {
        do {
            let canyon = try await service.canyon(for: self.canyonId)
            self.canyon = canyon
            
            isFavorite = self.favoriteService.isFavorite(canyon: canyon)
            
            do {
                let solar = try self.solarService.sunTimes(for: canyon.coordinate.asCLObject)
                do {
                    let weather = try await self.weatherService.requestCurrentWeatherForLocation(
                        lat: canyon.coordinate.latitude,
                        long: canyon.coordinate.longitude
                    )
                    forecast = ThreeDayForecast(
                        today: weather.requested.dayDetails,
                        tomorrow: weather.next?.dayDetails,
                        dayAfterTomorrow: weather.dayAfter?.dayDetails,
                        sunsetDetails: Strings.sunsetTimes(sunset: solar.sunset, sunrise: solar.sunrise)
                    )
                } catch {
                    Global.logger.error(error)
                    forecast = ThreeDayForecast(
                        today: nil,
                        tomorrow: nil,
                        dayAfterTomorrow: nil,
                        sunsetDetails: Strings.sunsetTimes(sunset: solar.sunset, sunrise: solar.sunrise)
                    )
                }
            } catch {
                Global.logger.error(error)
            }
        } catch {
            Global.logger.error(error)
        }
    }
    
    public func toggleFavorite() {
        guard let canyon = canyon else { return }
        
        let isFavorited = favoriteService.isFavorite(canyon: canyon)
        favoriteService.setFavorite(canyon: canyon, to: !isFavorited)
        isFavorite = !isFavorited
    }
    
    public func requestDownloadGPX() {
        defer { gpxLoader.stopLoading() }
        guard let canyon = canyon else { return }

        gpxLoader.startLoading(loadingType: .screen)
        guard let url = gpxService.gpxFileUrl(from: canyon) else {
            Global.logger.error("Could not create GPX file!")
            return
        }
        shareGPXFile = url
    }
}
