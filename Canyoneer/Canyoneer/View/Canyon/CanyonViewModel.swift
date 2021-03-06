//
//  CanyonViewModel.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation
import RxSwift

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
    
    // Rx
    public let canyonObservable: Observable<Canyon>
    private let canyonSubject: PublishSubject<Canyon>
    
    public let isFavorite: Observable<Bool>
    private let isFavoriteSubject: PublishSubject<Bool>
    
    public let forecast: Observable<ThreeDayForecast>
    private let forecastSubject: PublishSubject<ThreeDayForecast>
    
    public let shareGPXFile: Observable<URL>
    private let shareGPXFileSubject: PublishSubject<URL>
    
    // state
    public let gpxLoader = LoadingComponent()
    public var canyon: Canyon?
    private let canyonId: String
    
    // objects
    private let service: RopeWikiServiceInterface
    private let favoriteService = FavoriteService()
    private let weatherService: WeatherService = NOAAWeatherService()
    private let gpxService = GPXService()
    private let solarService = SolarService()
    private let bag = DisposeBag()
    
    init(canyonId: String, service: RopeWikiServiceInterface = RopeWikiService()) {
        self.canyonId = canyonId
        self.service = service
        
        self.canyonSubject = PublishSubject()
        self.canyonObservable = self.canyonSubject.asObservable()
        
        self.isFavoriteSubject = PublishSubject()
        self.isFavorite = self.isFavoriteSubject.asObservable()
        
        self.forecastSubject = PublishSubject()
        self.forecast = self.forecastSubject.asObservable()
        
        self.shareGPXFileSubject = PublishSubject()
        self.shareGPXFile = self.shareGPXFileSubject.asObservable()
    }
    
    // MARK: Actions
    public func refresh() {
        self.service.canyon(for: self.canyonId).subscribe { [weak self] canyon in
            guard let self = self else { return }
            guard let canyon = canyon else { return }
            self.canyon = canyon
            self.canyonSubject.onNext(canyon)
            
            let isFavorite = self.favoriteService.isFavorite(canyon: canyon)
            self.isFavoriteSubject.onNext(isFavorite)
            
            let weatherRequest = self.weatherService.requestCurrentWeatherForLocation(
                lat: canyon.coordinate.latitude,
                long: canyon.coordinate.longitude
            )
            let solarRequest = self.solarService.sunTimes(for: canyon.coordinate.asCLObject).asObservable()
            Observable.zip(weatherRequest, solarRequest)
                .subscribeOnNext({ tuple in
                let (weather, solar) = tuple
                guard let details = weather else {
                    DispatchQueue.main.async {
                        let data = ThreeDayForecast(
                            today: nil,
                            tomorrow: nil,
                            dayAfterTomorrow: nil,
                            sunsetDetails: Strings.sunsetTimes(sunset: solar.sunset, sunrise: solar.sunrise)
                        )
                        self.forecastSubject.onNext(data)
                    }
                    return
                }
                let forecast = ThreeDayForecast(
                    today: details.requested.dayDetails,
                    tomorrow: details.next?.dayDetails,
                    dayAfterTomorrow: details.dayAfter?.dayDetails,
                    sunsetDetails: Strings.sunsetTimes(sunset: solar.sunset, sunrise: solar.sunrise)
                )
                DispatchQueue.main.async {
                    self.forecastSubject.onNext(forecast)
                }
                }).disposed(by: self.bag)
            
        } onFailure: { error in
            Global.logger.error(error)
        }.disposed(by: self.bag)
    }
    
    public func toggleFavorite() {
        guard let canyon = canyon else { return }
        
        let isFavorited = favoriteService.isFavorite(canyon: canyon)
        favoriteService.setFavorite(canyon: canyon, to: !isFavorited)
        self.isFavoriteSubject.onNext(!isFavorited)
    }
    
    public func requestDownloadGPX() {
        defer { gpxLoader.stopLoading() }
        guard let canyon = canyon else { return }

        gpxLoader.startLoading(loadingType: .screen)
        guard let url = gpxService.gpxFileUrl(from: canyon) else {
            Global.logger.error("Could not create GPX file!")
            return
        }
        self.shareGPXFileSubject.onNext(url)                
    }
}
