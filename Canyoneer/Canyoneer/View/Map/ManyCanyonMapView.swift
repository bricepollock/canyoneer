//  Created by Brice Pollock for Canyoneer on 3/8/24

import Foundation
import SwiftUI
import CoreLocation

fileprivate enum Strings {
    static let showTopoLines = "Show Route Lines"
    static let legend = "Legend"
}

struct ManyCanyonMapView: View {
    @ObservedObject var viewModel: ManyCanyonMapViewModel
        
    @State var showLegendSheet: Bool = false
    @State var showTopoLines: Bool
    @State var showFiltersSheet: Bool = false
    @State var showCanyonsOnMap: Bool = false
    
    init(viewModel: ManyCanyonMapViewModel) {
        self.viewModel = viewModel
        self.showTopoLines = viewModel.showTopoLines
    }
    
    @ViewBuilder
    var body: some View {
        NavigationStack {
            Group {
                MapboxMapView(viewModel: viewModel.mapViewModel)
                    .onAppear {
                        viewModel.didAppear()
                    }
            }
            .overlay(alignment: .bottomTrailing) {
                if viewModel.showOverlays {
                    VStack {
                        HStack(spacing: Grid.medium) {
                            Spacer()
                            ImageButton(system: "list.bullet.rectangle") {
                                showCanyonsOnMap = true
                            }
                            ImageButton(system: "line.3.horizontal.decrease.circle") {
                                showFiltersSheet = true
                            }
                        }
                        .padding(Grid.medium)
                        
                        Spacer()
                        if viewModel.canRenderTopoLines {
                            HStack {
                                Spacer()
                                Toggle(isOn: $showTopoLines) {
                                    HStack {
                                        Spacer()
                                        Text(Strings.showTopoLines)
                                            .font(FontBook.Subhead.emphasis)
                                    }
                                }
                                .onChange(of: showTopoLines) { shouldShow in
                                    viewModel.showTopoLines = shouldShow
                                }
                            }
                        }
                        HStack {
                            Spacer()
                            Button(action: {
                                self.showLegendSheet = true
                            }, label: {
                                Text(Strings.legend)
                                    .font(FontBook.Subhead.emphasis)
                            })
                            // Avoid the mapbox (i)
                            .offset(x: -38, y: -10)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showCanyonsOnMap) {
                ResultListView(
                    viewModel: MapListViewModel(
                        canyonsOnMap: viewModel.visibleCanyons,
                        filterViewModel: viewModel.filterViewModel,
                        filterSheetViewModel: viewModel.filterSheetViewModel,
                        weatherViewModel: viewModel.weatherViewModel,
                        canyonManager: viewModel.canyonManager,
                        favoriteService: viewModel.favoriteService,
                        locationService: viewModel.locationService
                    )
                )
            }
            .navigationDestination(isPresented: $viewModel.showCanyonDetails) {
                if let canyonID = viewModel.showCanyonWithID {
                    CanyonView(
                        viewModel: CanyonViewModel(
                            canyonId: canyonID,
                            canyonManager: viewModel.canyonManager,
                            locationService: viewModel.locationService,
                            favoriteService: viewModel.favoriteService,
                            weatherViewModel: viewModel.weatherViewModel
                        )
                    )
                } else {
                    EmptyView()
                }
            }
        }
        .sheet(isPresented: $showLegendSheet) {
            MapLegendView()
        }
        .sheet(isPresented: $showFiltersSheet) {
            CanyonFilterSheetView(viewModel: self.viewModel.filterSheetViewModel)
        }
    }
}
