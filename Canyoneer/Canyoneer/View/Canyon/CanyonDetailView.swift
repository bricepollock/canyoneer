//
//  CanyonDetailView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct CanyonDetailView: View {
    static let horizontalPadding: CGFloat = 12
    
    @ObservedObject var viewModel: CanyonDetailViewModel
    @Environment(\.currentTab) var tab
    @Environment(\.toastMessage) var toastMessage
    
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
            location
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
    var location: some View {
        VStack(spacing: Grid.medium) {
            Text(Strings.location)
                .font(FontBook.Body.emphasis)
                .asCanyonHeader()
            
            HStack(spacing: Grid.small) {
                Text(Strings.coordinate)
                    .font(FontBook.Body.emphasis)
                Text(viewModel.canyonCoordinate)
                    .font(FontBook.Body.regular)
                Button {
                    UIPasteboard.general.setValue(viewModel.canyonCoordinate, forPasteboardType: UTType.plainText.identifier)
                    toastMessage.wrappedValue = Strings.coordinateCopied
                } label: {
                    Image(systemName: "doc.on.doc")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(ColorPalette.Color.action)
                        .frame(width: Constants.copyImageSize, height: Constants.copyImageSize)
                }
                Spacer()
            }
            .padding(.horizontal, Self.horizontalPadding)
            
            if viewModel.showOnMapVisible {
                ContainedButton(title: Strings.goToOnMap) {
                    Task(priority: .userInitiated) { @MainActor in
                        tab.wrappedValue = .map
                        viewModel.showOnMap()
                    }
                }
                .padding(.top, Grid.xSmall)
                .padding(.horizontal, Self.horizontalPadding)
            }
        }
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

            ContainedButton(title: Strings.launchDirections) {
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
        static let copyImageSize: CGFloat = 16
    }
            
    private enum Strings {
        // section titles
        static let summary = "Summary"
        static let location = "Location"
        static let details = "Details"
        static let weather = "Weather"
        static let directions = "Directions"
        static let description = "Description"
        
        // Location
        static let coordinate = "Coordinate:"
        static let coordinateCopied = "Coordinates Copied"
                    
        // Months
        static let season = "Best Months"
        
        // Description
        static let creativeCommons = "This information is licensed from Ropewiki under Creative Commons"
        
        // Actions
        static let ropeWiki = "Ropewiki Page"
        static let goToOnMap = "Go to on Map"
        static let launchDirections = "Open in Apple Maps"
    }
}
