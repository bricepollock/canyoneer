//  Created by Brice Pollock for Canyoneer on 3/8/24

import Foundation
import SwiftUI
import CoreLocation

struct SingleCanyonMapView: View {
    @ObservedObject var viewModel: SingleCanyonMapViewModel
    
    init(viewModel: SingleCanyonMapViewModel) {
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    var body: some View {
        Group {
            MapboxMapView(viewModel: viewModel.mapViewModel)
                .onAppear {
                    viewModel.onAppear()
                }.ignoresSafeArea(edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(ColorPalette.Color.canyonTan, for: .navigationBar)
        .overlay(alignment: .bottomTrailing) {
            HStack {
                Spacer()
                VStack(spacing: Grid.medium) {
                    MapButton(system: viewModel.isAtCurrentLocation ? "location.fill" : "location") {
                        Task(priority: .userInitiated) { [weak viewModel] in
                            await viewModel?.goToCurrentLocation()
                        }
                    }
                    Spacer()
                }
            }
            .padding(Grid.medium)
        }
    }
}
