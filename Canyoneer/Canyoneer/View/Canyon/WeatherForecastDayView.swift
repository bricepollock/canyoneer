//
//  WeatherForecastDay.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import UIKit

class WeatherForecastDayView: UIStackView {
    
    private let tempLabel = UILabel()
    private let precipLabel = UILabel()
    private let dayLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        self.axis = .vertical
        self.spacing = .small
        self.addArrangedSubview(self.tempLabel)
        self.addArrangedSubview(self.precipLabel)
        self.addArrangedSubview(self.dayLabel)
        
        self.tempLabel.font = FontBook.Body.regular
        self.tempLabel.textAlignment = .center
        
        self.precipLabel.font = FontBook.Body.regular
        self.precipLabel.textAlignment = .center
        
        self.dayLabel.font = FontBook.Body.emphasis
        self.dayLabel.textAlignment = .center
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: DayWeatherDetails) {
        self.tempLabel.text = data.temp
        self.precipLabel.text = data.precip
        self.dayLabel.text = data.dayOfWeek
    }
}
