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
        static let error = "Weather Not Found"
    }
    
    private let loader = LoadingComponent()
    private let daysStack = UIStackView()
    private let today = WeatherForecastDayView()
    private let tomorrow = WeatherForecastDayView()
    private let dayAfter = WeatherForecastDayView()
    private let daylightHours = UILabel()
    
    private let errorLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        self.axis = .vertical
        self.spacing = .medium
        self.alignment = .center
        self.addArrangedSubview(self.daysStack)
        self.addArrangedSubview(self.daylightHours)
        
        self.daylightHours.font = FontBook.Body.regular
        
        self.daysStack.axis = .horizontal
        self.daysStack.spacing = .medium
        self.daysStack.alignment = .center
        self.daysStack.distribution = .fillEqually
        
        self.daysStack.addArrangedSubview(today)
        self.daysStack.addArrangedSubview(tomorrow)
        self.daysStack.addArrangedSubview(dayAfter)
        
        self.addSubview(self.loader.inlineLoader)
        self.loader.inlineLoader.constrain.centerX(on: self)
        self.loader.inlineLoader.constrain.centerY(on: self)
        self.loader.startLoading(loadingType: .inline)
        
        self.errorLabel.text = Strings.error
        self.errorLabel.font = FontBook.Body.regular
        self.errorLabel.isHidden = true
        self.addSubview(self.errorLabel)
        self.errorLabel.constrain.centerX(on: self)
        self.errorLabel.constrain.centerY(on: self)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: ThreeDayForecast?) {
        defer { self.loader.stopLoading() }
        guard let data = data, let today = data.today, let tomorrow = data.tomorrow, let dayAfter = data.dayAfterTomorrow else {
            self.errorLabel.isHidden = false
            return
        }
        self.today.configure(with: today)
        self.tomorrow.configure(with: tomorrow)
        self.dayAfter.configure(with: dayAfter)
        self.daylightHours.text = data.sunsetDetails
    }
}
