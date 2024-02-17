//  Created by Brice Pollock for Canyoneer on 12/2/23

import SwiftUI

enum AppTab: CaseIterable {
    case map
    case favorites
    case search
    
    var index: Int {
        switch self {
        case .favorites: return 0
        case .map: return 1
        case .search: return 2
        }
    }
    
    var icon: UIImage {
        switch self {
        case .map: return UIImage(systemName: "map")!
        case .favorites: return UIImage(systemName: "star")!
        case .search: return UIImage(systemName: "magnifyingglass")!
        }
    }
    
    var title: String {
        switch self {
        case .map: return "Map"
        case .favorites: return "Favorites"
        case .search: return "Search"
        }
    }
}

@MainActor
class MainTabViewModel: ObservableObject {
    @Published var currentTab: AppTab
    
    let tabs: [AppTab]
    let mapViewModel: MapViewModel
    let favoriteViewModel: FavoriteListViewModel
    let searchViewModel: SearchViewModel
    
    init(
        allCanyons: [CanyonIndex],
        canyonManager: CanyonDataManaging,
        filterViewModel: CanyonFilterViewModel,
        weatherViewModel: WeatherViewModel,
        mapService: MapService,
        favoriteService: FavoriteServing
    ) {
        self.tabs = AppTab.allCases.sorted { $0.index < $1.index }
        self.currentTab = .favorites
        
        mapViewModel = MapViewModel(
            type: .apple,
            allCanyons: allCanyons,
            applyFilters: true,
            showOverlays: true,
            filterViewModel: filterViewModel,
            weatherViewModel: weatherViewModel,
            canyonManager: canyonManager,
            favoriteService: favoriteService
        )
        favoriteViewModel = FavoriteListViewModel(
            weatherViewModel: weatherViewModel,
            mapService: mapService, 
            canyonManager: canyonManager,
            favoriteService: favoriteService
        )
        
        searchViewModel = SearchViewModel(
            searchService: SearchService(canyonManager: canyonManager),
            filterViewModel: filterViewModel,
            weatherViewModel: weatherViewModel,
            canyonManager: canyonManager,
            favoriteService: favoriteService
        )        
    }
    
}

struct MainTabView: View {
    @ObservedObject var viewModel: MainTabViewModel
    
    var body: some View {
        TabView(selection: $viewModel.currentTab) {
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
            MapView(viewModel: viewModel.mapViewModel)
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
    }
}
