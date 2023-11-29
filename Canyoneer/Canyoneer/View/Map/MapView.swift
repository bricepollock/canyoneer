//
//  MapViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import SwiftUI
import CoreLocation

fileprivate enum Strings {
    static let showTopoLines = "Show Route Lines"
    static let legend = "Legend"
}

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel
        
    @State var showLegend: Bool = false
    @State var showTopoLines: Bool = true
    @State var showFilters: Bool = false
    @State var showCanyonsOnMap: Bool = false
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.mapView {
                case .apple(let view):
                    view
                case .mapbox(let view):
                    view
                }
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
                    .padding(Grid.medium)
                }
            }
            .navigationDestination(isPresented: $showCanyonsOnMap) {
                ResultListView(
                    viewModel: MapListViewModel(
                        canyonsOnMap: viewModel.canyonMapViewOwner.visibleCanyons,
                        filterViewModel: viewModel.filterViewModel,
                        weatherViewModel: viewModel.weatherViewModel,
                        canyonService: viewModel.canyonService,
                        favoriteService: viewModel.favoriteService
                    )
                )
            }
            .navigationDestination(isPresented: $viewModel.showCanyonDetails) {
                if let canyonID = viewModel.showCanyonWithID {
                    CanyonView(
                        viewModel: CanyonViewModel(
                            canyonId: canyonID,
                            canyonService: viewModel.canyonService,
                            filterViewModel: viewModel.filterViewModel,
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
            if showTopoLines {
                viewModel.canyonMapViewOwner.renderPolylinesFromCache()
            } else {
                viewModel.canyonMapViewOwner.removePolylines()
            }
        }
        .sheet(isPresented: $showLegend) {
            MapLegendView()
        }
        .sheet(isPresented: $showFilters) {
            CanyonFilterSheetView(
                viewModel: CanyonFilterSheetViewModel(
                    filterViewModel: self.viewModel.filterViewModel
                )
            )
        }
    }
}
