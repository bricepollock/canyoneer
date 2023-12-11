//  Created by Brice Pollock for Canyoneer on 11/30/23

import SwiftUI
import CoreLocation

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
    private enum Strings {
        static func temp(max: Double, min: Double) -> String {
            return "\(Int(min)) - \(Int(max)) °F"
        }
        static func precip(chance: Double) -> String {
            let percentage = chance * 100
            return "\(String(Int(percentage)))% Moisture"
        }
    }
    
    func dayDetails(timezone: TimeZone = .current) -> DayWeatherDetails? {
        guard let max = self.temperatureMax, let min = self.temperatureMin, let precip = self.precipProbability, let date = self.time else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = timezone
        let dayOfWeek = dateFormatter.string(from: date).capitalized
        
        return DayWeatherDetails(
            temp: Strings.temp(max: max, min: min),
            precip: Strings.precip(chance: precip),
            dayOfWeek: dayOfWeek
        )
    }
}

@MainActor
class WeatherViewModel: ObservableObject {
    private let weatherService: WeatherService
    private let solarService: SolarService
    
    init(
        weatherService: WeatherService = NOAAWeatherService(),
        solarService: SolarService = SolarService()
    ) {
        self.weatherService = weatherService
        self.solarService = solarService
    }
    
    func fetch(at location: Coordinate) async throws -> ThreeDayForecast {
        let solar = try self.solarService.sunTimes(for: location)
        let sunDetails = Strings.sunsetTimes(sunset: solar.sunset, sunrise: solar.sunrise)
        do {
            let weather = try await self.weatherService.requestCurrentWeatherForLocation(
                lat: location.latitude,
                long: location.longitude
            )
            return ThreeDayForecast(
                today: weather.requested.dayDetails(),
                tomorrow: weather.next?.dayDetails(),
                dayAfterTomorrow: weather.dayAfter?.dayDetails(),
                sunsetDetails: sunDetails
            )
        } catch {
            Global.logger.error(error)
            return ThreeDayForecast(
                today: nil,
                tomorrow: nil,
                dayAfterTomorrow: nil,
                sunsetDetails: sunDetails
            )
        }
    }
    
    internal enum Strings {
        static func sunsetTimes(sunset: Date, sunrise: Date, in timezone: TimeZone = .current) -> String {
            let formatter = DateFormatter()
            formatter.timeZone = timezone
            formatter.dateFormat = "h:mm a"
                        
            let sunsetTime = formatter.string(from: sunset)
            let sunriseTime = formatter.string(from: sunrise)
            
            let time = sunset.timeIntervalSince(sunrise) / 60 / 60
            let hours = Int(time.rounded(.toNearestOrEven))
            return "Daylight: \(sunriseTime) - \(sunsetTime) (\(hours) hours)"
        }
    }
}
