//
//  CanyonViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import SwiftUI

struct CanyonView: View {
    @StateObject var viewModel: CanyonViewModel
    
    @State var showMapDetails: Bool = false
    @State var showCanyonShareSheet: Bool = false
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: Grid.medium) {
            ScrollView {
                if let details = viewModel.detailViewModel {
                    CanyonDetailView(viewModel: details)
                } else {
                    EmptyView()
                }

            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.refresh()
        }
        .overlay {
            if viewModel.isLoading {
                LargeProgressView()
            } else {
                EmptyView()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                ImageButton(image: viewModel.isFavorite ? UIImage(systemName: "star.fill")! :  UIImage(systemName: "star")!) {
                    viewModel.toggleFavorite()
                }
                ImageButton(system: "square.and.arrow.up") {
                    showCanyonShareSheet = true
                }
                ImageButton(system: "map") {
                    showMapDetails = true
                }
                ImageButton(system: "square.and.arrow.down") {
                    viewModel.requestDownloadGPX()
                }
            }
        }
        .sheet(isPresented: $showCanyonShareSheet) {
            ShareSheetView(activityItems: [viewModel], excludedActivityTypes: nil)
        }
        .sheet(isPresented: $viewModel.showGPXShareSheet) {
            if let url = viewModel.gpxFileURL {
                ShareSheetView(activityItems: [url], excludedActivityTypes: nil)
            } else {
                EmptyView()
            }
        }
        .navigationDestination(isPresented: $showMapDetails) {
            if let singleCanyonViewModel = viewModel.singleCanyonViewModel {
                MapboxMapView(viewModel: singleCanyonViewModel.mapViewModel)
                    .onAppear {
                        singleCanyonViewModel.onAppear()
                    }
            } else {
                EmptyView()
            }
        }
    }
}
