//
//  WeatherForecastView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import SwiftUI

@MainActor
class WeatherForecastViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var forecast: ThreeDayForecast?
    
    private let coordinate: Coordinate
    private let weatherViewModel: WeatherViewModel
    
    init(for coordinate: Coordinate, weatherViewModel: WeatherViewModel) {
        self.weatherViewModel = weatherViewModel
        self.coordinate = coordinate
    }
    
    func refresh() async {
        self.isLoading = true
        defer { self.isLoading = false}
        
        do {
            self.forecast = try await weatherViewModel.fetch(at: coordinate)
        } catch {
            Global.logger.error(error)
        }
    }
}

struct WeatherForecastView: View {
    @ObservedObject var viewModel: WeatherForecastViewModel
    
    @ViewBuilder
    var body: some View {
        VStack(alignment: .center, spacing: Grid.medium) {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }                
            } else if let forecast = viewModel.forecast {
                // Allows partial failure of view
                if let today = forecast.today, let tomorrow = forecast.tomorrow, let dayAfter = forecast.dayAfterTomorrow {
                    HStack(alignment: .center, spacing: Grid.medium) {
                        WeatherForecastDayView(forecast: today)
                        WeatherForecastDayView(forecast: tomorrow)
                        WeatherForecastDayView(forecast: dayAfter)
                    }
                } else {
                    Text(Strings.error)
                        .font(FontBook.Body.regular)
                }
                Text(forecast.sunsetDetails)
                    .font(FontBook.Body.regular)
            } else {
                Text(Strings.error)
                    .font(FontBook.Body.regular)
            }
        }.task {
            await viewModel.refresh()
        }
    }
    
    private enum Strings {
        static let error = "Weather Not Found"
    }
}
