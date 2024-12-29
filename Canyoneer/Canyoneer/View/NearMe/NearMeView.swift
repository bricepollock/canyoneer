//
//  NearMeViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import SwiftUI

struct NearMeView: View {
    @ObservedObject var viewModel: NearMeViewModel
    @State var showFilters: Bool = false
    @State var showOnMap: Bool = false
        
    var body: some View {
        VStack {
            ResultListView(viewModel: viewModel)
        }
        .task {
            await viewModel.refresh()
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                ImageButton(system: "map") {
                    showOnMap = true
                }
                ImageButton(system: viewModel.anyFiltersActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle") {
                    showFilters = true
                }
            }
        }
        .navigationDestination(isPresented: $showOnMap) {
            if let mapViewModel = viewModel.mapViewModel {
                ManyCanyonMapView(viewModel: mapViewModel)
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                EmptyView()
            }
        }.sheet(isPresented: $showFilters) {
            CanyonFilterSheetView(viewModel: viewModel.filterSheetViewModel)
        }
    }
}
