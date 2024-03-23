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
            VStack(spacing: Grid.medium) {
                ForEach(viewModel.results) { result in
                    if result.id != viewModel.results.first?.id {
                        Divider()
                    }
                    NavigationLink {
                        CanyonView(
                            viewModel: CanyonViewModel(
                                canyonId: result.id,
                                canyonManager: viewModel.canyonManager,
                                locationService: viewModel.locationService,
                                favoriteService: viewModel.favoriteService,
                                weatherViewModel: viewModel.weatherViewModel

                            )
                        )
                    } label: {
                        CanyonItemView(result: result)
                    }.buttonStyle(.plain)
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
}
