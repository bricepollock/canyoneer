//
//  CanyonDetailView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import SwiftUI

struct CanyonDetailView: View {
    static let horizontalPadding: CGFloat = 12
    
    @ObservedObject var viewModel: CanyonDetailViewModel
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: Grid.medium) {
            Text(viewModel.canyonName)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .font(FontBook.Heading.emphasis)
            summary
            canyonDetails
            monthSummary
            weather
            directions
            htmlDescription
        }
        .padding(.vertical, Grid.small)        
    }
    
    @ViewBuilder
    var summary: some View {
        VStack {
            HStack(spacing: Grid.small) {
                Text(Strings.summary)
                    .font(FontBook.Body.emphasis)
                StarQualityView(viewModel: viewModel.starViewModel)
            }
            .asCanyonHeader()
            
            HStack(alignment: .center) {
                Text(viewModel.canyonSummary)
                    .font(FontBook.Body.regular)
                Spacer()
                if let ropeWikiURL = viewModel.ropeWikiURL {
                    Link(Strings.ropeWiki, destination: ropeWikiURL)
                }
            }
            .padding(.horizontal, Self.horizontalPadding)
            .padding(.vertical, Grid.small)
        }
    }
    
    @ViewBuilder
    var canyonDetails: some View {
        VStack(spacing: Grid.medium) {
            Text(Strings.details)
                .font(FontBook.Body.emphasis)
                .asCanyonHeader()
            DataTableView(viewModel: viewModel.tableData)
        }
    }
    
    @ViewBuilder
    var monthSummary: some View {
        BestSeasonsView(viewModel: viewModel.bestMonths)
    }
    
    @ViewBuilder
    var weather: some View {
        VStack {
            Text(Strings.weather)
                .font(FontBook.Body.emphasis)
                .asCanyonHeader()

            WeatherForecastView(viewModel: viewModel.weatherViewModel)
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    var directions: some View {
        VStack {
            Text(Strings.directions)
                .font(FontBook.Body.emphasis)
                .asCanyonHeader()

            ContainedButton(title: Strings.openInMaps) {
                viewModel.launchDirections()
            }
            .padding(.top, Grid.xSmall)
            .padding(.horizontal, Self.horizontalPadding)
        }
    }
    
    @ViewBuilder
    var htmlDescription: some View {
        VStack {
            Text(Strings.description)
                .font(FontBook.Body.emphasis)
                .asCanyonHeader()

            WebView(htmlString: viewModel.htmlString, delegate: viewModel)
                .frame(minHeight: viewModel.webViewHeight)
                .padding(.horizontal, Self.horizontalPadding)
            
            Text(Strings.creativeCommons)
                .font(FontBook.Body.regular)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Grid.medium)
        }
    }
    
    enum Constants {
        static let headerTitlePadding: CGFloat = 2
    }
            
    private enum Strings {
        // section titles
        static let summary = "Summary"
        static let details = "Details"
        static let weather = "Weather"
        static let directions = "Directions"
        static let description = "Description"
                    
        // Months
        static let season = "Best Months"
        
        // Description
        static let creativeCommons = "This information is licensed from Ropewiki under Creative Commons"
        
        // Actions
        static let ropeWiki = "Ropewiki Page"
        static let openInMaps = "Open in Apple Maps"
    }
}
