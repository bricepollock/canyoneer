//
//  WeatherForecastView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import UIKit

class WeatherForecastView: UIStackView {
    
    enum Strings {
        static let yesterday = "Yesterday"
        static let today = "Today"
        static let tomorrow = "Tomorrow"
        static let dayAfterTomorrow = "Day After"
    }
    
    private let loader = LoadingComponent()
    private let yesterday = WeatherForecastDayView()
    private let today = WeatherForecastDayView()
    private let tomorrow = WeatherForecastDayView()
    
    init() {
        super.init(frame: .zero)
        self.axis = .horizontal
        self.spacing = .medium
        self.alignment = .center
        self.distribution = .equalCentering
        
        self.addArrangedSubview(UIView())
        self.addArrangedSubview(yesterday)
        self.addArrangedSubview(today)
        self.addArrangedSubview(tomorrow)
        self.addArrangedSubview(UIView())
        
        self.addSubview(self.loader.inlineLoader)
        self.loader.inlineLoader.constrain.centerX(on: self)
        self.loader.inlineLoader.constrain.centerY(on: self)
        
        self.loader.startLoading(loadingType: .inline)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: ThreeDayForecast) {
        // yesterday is currently unsupported
        self.yesterday.isHidden = true
        self.today.configure(with: data.today, day: Strings.today)
        self.tomorrow.configure(with: data.tomorrow, day: Strings.tomorrow)
        self.loader.stopLoading()
    }
}
