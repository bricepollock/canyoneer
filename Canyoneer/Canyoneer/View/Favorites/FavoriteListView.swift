//  Created by Brice Pollock on 1/18/22.

import Foundation
import SwiftUI

struct FavoriteListView: View {
    @ObservedObject var viewModel: FavoriteListViewModel
    @State var showFilters: Bool = false
    @State var showOnMap: Bool = false
    @State var showProfile: Bool = false
        
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.results.isEmpty {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(Strings.addFavorites)
                            .font(FontBook.Body.regular)
                            .foregroundColor(ColorPalette.GrayScale.gray)
                        Spacer()
                    }
                    Spacer()
                } else {
                    ResultListView(viewModel: viewModel)
                }
            }
            .task {
                await viewModel.refresh()
            }
            .overlay(alignment: .top) {
                if viewModel.isDownloading {
                    DownloadBar(progress: $viewModel.progress)
                        .padding(Grid.medium)
                    Spacer()
                }
            }
            .navigationTitle(Strings.favorites)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showProfile = true
                    }, label: {
                        ZStack {
                            Image(uiImage: UIImage(imageLiteralResourceName: "icon_app"))
                                .resizable()
                                .scaledToFit()
                                .frame(width: Constants.profileButtonSize, height: Constants.profileButtonSize)
                                .cornerRadius(0.5 * Constants.profileButtonSize)
                            
                            if viewModel.badgeProfile {
                                Circle()
                                    .fill(ColorPalette.Color.warning)
                                    .frame(width: Constants.badgeSize, height: Constants.badgeSize)
                                    .position(x: Constants.profileButtonSize - 0.15*Constants.profileButtonSize, y: Constants.profileButtonSize - 0.15*Constants.profileButtonSize)
                            }
                        }
                    })
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    ImageButton(image: viewModel.hasDownloadedAll ? UIImage(systemName: "arrow.down.circle.fill")! : UIImage(systemName: "arrow.down.circle")!) {
                        Task(priority: .userInitiated) { @MainActor in
                            await viewModel.downloadCanyonMaps()
                        }
                    }
                    .popoverTip(CanyoneerTips.downloadFavorites)
                    
                    ImageButton(system: "line.3.horizontal.decrease.circle") {
                        showFilters = true
                    }
                    ImageButton(system: "map") {
                        showOnMap = true
                    }
                }
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView(viewModel: viewModel.profileViewModel)
                    .navigationBarTitleDisplayMode(.large)
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
    
    private enum Constants {
        static let profileButtonSize: CGFloat = 24
        static let badgeSize: CGFloat = 12
    }
    
    private enum Strings {
        static let favorites = "Favorites"
        static let addFavorites = "Add favorites to this list"
    }
}
