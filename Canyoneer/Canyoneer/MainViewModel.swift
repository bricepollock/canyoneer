//  Created by Brice Pollock for Canyoneer on 12/2/23

import Foundation
import SwiftUI
import Combine

struct UpdateBannerData {
    let text: String
    let background: Color
}

@MainActor
class MainViewModel: ObservableObject {
    @Published var isLoadingApp: Bool = true
    @Published var updateBanner: UpdateBannerData?
    
    var tabViewModel: MainTabViewModel?
    
    // Top-level app dependencies
    private let canyonManager: CanyonDataManaging
    private let filterViewModel: CanyonFilterViewModel
    private let weatherViewModel: WeatherViewModel
    private let mapService: MapService
    private let favoriteService: FavoriteServing
    private let updateManager: UpdateManager
    
    private var bag = Set<AnyCancellable>()
    
    init() {
        updateManager = UpdateManager.shared
        canyonManager = updateManager.canyonManager
        weatherViewModel =  WeatherViewModel()
        mapService =  MapService()
        favoriteService =  FavoriteService(canyonManager: canyonManager)
        
        // Right now we reset filter state on load
        filterViewModel = CanyonFilterViewModel(initialState: .default)
    }
    
    func loadApp() async {
        isLoadingApp = true
        
        // Check against bundle
        await updateManager.checkServerDataAgainstBundle()
        
        // load the canyon data
        let allCanyons = await canyonManager.canyons()
        
        // Load favorites
        await favoriteService.start()
        
        tabViewModel = MainTabViewModel(
            allCanyons: allCanyons,
            canyonManager: canyonManager,
            filterViewModel: filterViewModel,
            weatherViewModel: weatherViewModel,
            mapService: mapService,
            favoriteService: favoriteService,
            locationService: LocationService()
        )
        isLoadingApp = false
        
        // Update banner according to state
        updateManager.$isUpdatingDatabase
            .dropFirst()
            .sink { [weak self] isUpdating in
                guard let self else { return }
                if isUpdating {
                    self.updateBanner = UpdateBannerData(text: Strings.updating, background: ColorPalette.Color.action)
                // Is we were just updating...
                } else if updateManager.isUpdatingDatabase {
                    if self.updateManager.updateFailure == nil {
                        self.updateBanner = UpdateBannerData(text: Strings.success, background: ColorPalette.Color.green)
                    } else {
                        self.updateBanner = UpdateBannerData(text: Strings.failed, background: ColorPalette.Color.warning)
                    }
                    
                    Task(priority: .userInitiated) {
                        await self.delayDismissBanner()
                    }
                } else {
                    self.updateBanner = nil
                }
            }.store(in: &bag)
    }

    /// Delay dismiss so there is some time for the user to look at the banner with the status befor dismissal
    func delayDismissBanner() async {
        do {
            try await Task.sleep(for: .seconds(4))
        } catch {
            Global.logger.error("Failed to sleep with: \(error)")
        }
        updateBanner = nil
    }
            
    private enum Strings {
        static let updating = "Updating..."
        static let success = "Success!"
        static let failed = "Update Failed"
    }
}

