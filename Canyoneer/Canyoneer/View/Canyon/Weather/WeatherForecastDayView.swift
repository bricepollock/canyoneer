//
//  WeatherForecastDay.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import SwiftUI

struct WeatherForecastDayView: View {
    let forecast: DayWeatherDetails
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: Grid.small) {
            Text(forecast.temp)
                .font(FontBook.Body.regular)
                .multilineTextAlignment(.center)
            
            Text(forecast.precip)
                .font(FontBook.Body.regular)
                .multilineTextAlignment(.center)
            
            Text(forecast.dayOfWeek)
                .font(FontBook.Body.emphasis)
                .multilineTextAlignment(.center)
        }
    }
}
