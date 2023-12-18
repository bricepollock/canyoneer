//  Created by Brice Pollock for Canyoneer on 12/2/23

import Foundation
import SwiftUI
import BackgroundTasks

@MainActor
class MainViewModel: ObservableObject {
    static internal let appUpdateTaskKey = "index_update"
    
    @Published var isLoadingApp: Bool = true
    @Published var isUpdatingApp: Bool = false
    @Published var didUpdateFail: Bool = false
    
    var tabViewModel: MainTabViewModel?
    
    // Top-level app dependencies
    private let canyonService: CanyonAPIService
    private let filterViewModel: CanyonFilterViewModel
    private let weatherViewModel: WeatherViewModel
    private let mapService: MapService
    private let favoriteService: FavoriteService
    
    init() {
        canyonService = CanyonAPIService()
        weatherViewModel =  WeatherViewModel()
        mapService =  MapService()
        favoriteService =  FavoriteService(service: canyonService)
        
        // Right now we reset filter state on load
        filterViewModel = CanyonFilterViewModel(initialState: .default)
    }
    
    func loadApp() async {
        isLoadingApp = true
        
        // load the canyon data
        let allCanyons = await canyonService.canyons()
        
        // Load favorites
        await favoriteService.start()
        
        tabViewModel = MainTabViewModel(
            allCanyons: allCanyons,
            canyonService: canyonService,
            filterViewModel: filterViewModel,
            weatherViewModel: weatherViewModel,
            mapService: mapService,
            favoriteService: favoriteService
        )
        scheduleBackgroundUpdate()
        isLoadingApp = false
    }
        
    func scheduleBackgroundUpdate() {
        let request = BGAppRefreshTaskRequest(identifier: Self.appUpdateTaskKey)
        request.earliestBeginDate = Date()
        do {
            try BGTaskScheduler.shared.submit(request)
            Global.logger.debug("Scheduled background update")
        } catch(let error) {
            Global.logger.error("Background task scheduling error: \(error)")
        }
    }
    
    func updateAppFromServer() async {
        // Update from server
        do {
            // index_update
            Global.logger.debug("Checking for update")
            let newData = try await canyonService.canyonsRequiringUpdate()
            guard let newData, newData.requiredUpdates.isEmpty == false else {
                Global.logger.debug("No updates required")
                return
            }
            
            let start = Date()
            Global.logger.debug("Starting update for \(newData.requiredUpdates.count) canyons")
            
            isUpdatingApp = true
            try await canyonService.updateCanyons(from: newData)
            isUpdatingApp = false
            
            let updateDuration = Measurement(value: start.timeIntervalSince1970, unit: UnitDuration.seconds)
            Global.logger.debug("Update for \(newData.requiredUpdates.count) canyons took \(updateDuration)")
        } catch {
            Global.logger.error("Update failed with: \(error)")
            didUpdateFail = true
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                Global.logger.error("Failed to sleep with: \(error)")
            }
            isUpdatingApp = false
        }
    }
}
