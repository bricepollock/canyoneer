//  Created by Brice Pollock for Canyoneer on 12/2/23

import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: MainTabViewModel
    
    @State private var currentTab: AppTab = .favorites
    @State private var toastMessage: String?
    
    var body: some View {
        ZStack {
            tabView
            Group {
                if let toastMessage {
                    ToastView(message: toastMessage)
                }
            }
            .animation(.linear(duration: 0.3), value: toastMessage != nil)
            .transition(.opacity)

        }
        .environment(\.toastMessage, $toastMessage)
    }
    
    var tabView: some View {
        TabView(selection: $currentTab) {
            FavoriteListView(viewModel: viewModel.favoriteViewModel)
                .tag(AppTab.favorites)
                .tabItem {
                    Label(
                        title: {
                            Text(AppTab.favorites.title)
                        },
                        icon: {
                            Image(uiImage: AppTab.favorites.icon)
                        }
                    )
                }
            ManyCanyonMapView(viewModel: viewModel.mapViewModel)
                .tag(AppTab.map)
                .tabItem {
                    Label(
                        title: {
                            Text(AppTab.map.title)
                        },
                        icon: {
                            Image(uiImage: AppTab.map.icon)
                        }
                    )
                }
            SearchView(viewModel: viewModel.searchViewModel)
                .tag(AppTab.search)
                .tabItem {
                    Label(
                        title: {
                            Text(AppTab.search.title)
                        },
                        icon: {
                            Image(uiImage: AppTab.search.icon)
                        }
                    )
                }
        }
        .environment(\.currentTab, $currentTab)
    }
}
