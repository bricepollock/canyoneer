//
//  ResultsViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import UIKit
import SwiftUI

enum ResultListType: Int, Equatable {
    case search
    case nearMe
    case favorites
    case map
}

struct ResultListView: View {
    @StateObject var viewModel: ResultsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                ForEach(viewModel.results) { result in
                    NavigationLink {
                        CanyonView(
                            viewModel: CanyonViewModel(
                                canyonId: result.id,
                                canyonManager: viewModel.canyonManager,
                                locationService: viewModel.locationService,
                                favoriteService: viewModel.favoriteService,
                                weatherViewModel: viewModel.weatherViewModel,
                                mapDelegate: viewModel.mapDelegate
                            )
                        )
                    } label: {
                        CanyonItemView(result: result, isDisabled: false)
                    }.buttonStyle(.plain)
                    
                    Divider()
                }
                
                if !viewModel.hiddenResults.isEmpty {
                    HStack {
                        Text(Strings.hidden)
                            .font(FontBook.Body.emphasis)
                            .foregroundStyle(ColorPalette.GrayScale.dark)
                            .underline()
                            .padding(.top, Grid.medium)
                        
                        Spacer()
                    }
                    .padding(.horizontal, .medium)
                    .padding(.bottom, .medium)
                    .background(ColorPalette.GrayScale.extraLight)
                    
                    Divider()
                    
                    ForEach(viewModel.hiddenResults) { result in
                        CanyonItemView(result: result, isDisabled: true)
                        Divider()
                    }
                }
            }
        }.overlay {
            if viewModel.isLoading {
                LargeProgressView()
            } else {
                EmptyView()
            }
        }
        .navigationTitle(viewModel.title)
    }
         
     private enum Strings {
         static let hidden = "Favorites that don't match filters"
     }
}
