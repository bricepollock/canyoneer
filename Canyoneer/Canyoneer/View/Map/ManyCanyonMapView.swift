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
        
    @State var showLegend: Bool = false
    @State var showTopoLines: Bool = true
    @State var showFilters: Bool = false
    @State var showCanyonsOnMap: Bool = false
    
    init(viewModel: ManyCanyonMapViewModel) {
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    var body: some View {
        NavigationStack {
            Group {
                viewModel.mapView
            }
            .onAppear {
                viewModel.didAppear()
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
                                showFilters = true
                            }
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                self.showLegend = true
                            }, label: {
                                Text(Strings.legend)
                                    .font(FontBook.Subhead.emphasis)
                            })
                        }
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
                            }
                        }
                    }
                    .padding(Grid.medium)
                }
            }
            .navigationDestination(isPresented: $showCanyonsOnMap) {
                ResultListView(
                    viewModel: MapListViewModel(
                        canyonsOnMap: viewModel.mapOwner.visibleCanyons,
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
        .onChange(of: showTopoLines) { showTopoLines in
            // FIXME: We dropped support of TOPO lines on map to migrate to index file, when we address [ISSUE-6] we can use the mapbox tiles and avoid loading all KLM into memory which should allow us to put topo lines back on the map
            if showTopoLines {
                Task(priority: .userInitiated) {
                    do {
                        try await viewModel.mapOwner.renderCanyonPolylinesOnMap()
                    } catch {
                        Global.logger.error(error)
                    }
                }
                
            } else {
                viewModel.mapOwner.removeAllPolylines()
            }
        }
        .sheet(isPresented: $showLegend) {
            MapLegendView()
        }
        .sheet(isPresented: $showFilters) {
            CanyonFilterSheetView(viewModel: self.viewModel.filterSheetViewModel)
        }
    }
}
