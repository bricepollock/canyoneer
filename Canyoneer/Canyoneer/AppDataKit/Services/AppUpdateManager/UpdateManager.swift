//  Created by Brice Pollock for Canyoneer on 2/16/24

import Foundation
import BackgroundTasks

/// The goal of the update manager is to limit the need for a user to watch our updating screen to ensure the app updates.
///
/// Ways to update:
/// * Trigger manual update, watch the screen
/// * Trigger manual update, background the app (should still complete)
/// * Auto-update schedules approx. every week and updates everything so a user never notices the app is updating "it just works"
@MainActor class UpdateManager {
    static let shared: UpdateManager = UpdateManager()
    
    @Published var serverHasDatabaseUpdate: Bool = false
    @Published var isUpdatingDatabase: Bool = false
    @Published var updateFailure: String?
    
    /// When was the last time we manually updated the data bundled with the app. (September 24, 2024)
    let bundledDataUpdatedAt = Date(timeIntervalSince1970: 1727189835)
    
    var secondsBetweenUpdates: Double {
        Constants.updateInterval.converted(to: .seconds).value
    }
    
    var nextScheduledUpdate: Date? {
        // If we failed or haven't updated before, then we are overdue for an update
        guard let lastUpdate = statusRecorder.lastUpdate, lastUpdate.status == .success else {
            return nil
        }
        return lastUpdate.time.addingTimeInterval(secondsBetweenUpdates)
    }
    
    /// Ideally this should be the only instance in the app
    public let canyonManager: CanyonDataUpdating
    private let statusRecorder: UserDefaults = UserDefaults.standard
    internal init(canyonManager: CanyonDataUpdating = CanyonDataManager()) {
        self.canyonManager = canyonManager
    }
    
    func registerForBackgroundTask() {
        Global.logger.debug("Registered for BGAppRefreshTask")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.appUpdateTaskKey, using: nil) { task in
            guard let backgroundTask = task as? BGAppRefreshTask else {
                #if DEBUG
                self.completedUpdateNotify(with: IndexUpdateError.unknown("Cannot run background update: Unknown Task Type!"))
                #endif
                return
            }
            self.runBackgroundUpdate(backgroundTask: backgroundTask)
        }
    }
    
    /// Reschedule the background update task
    /// - NOTE: BGTask only works on device and not on simulator
    /// - Note: No worries about oversubmitting: "When you resubmit a task, the new submission replaces the previous submission."
    /// - Note: Can trigger by pausing app in debugger on device and running:
    /// ```e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"backcountry_nomad_canyoneer_index_update"]```
    func scheduleBackgroundUpdate() {
        let request = BGAppRefreshTaskRequest(identifier: Constants.appUpdateTaskKey)
        if let next = nextScheduledUpdate {
            request.earliestBeginDate = next
        }
        
        do {
            try BGTaskScheduler.shared.submit(request)
            Global.logger.debug("Scheduled background update in: \(DateComponentsFormatter.duration(for: self.nextScheduledUpdate?.timeIntervalSinceNow ?? 0))")
            
            #if DEBUG
            didRegisterNotify(error: nil)
            #endif
        } catch(let error) {
            Global.logger.error("Background task scheduling error: \(error)")
            #if DEBUG
            didRegisterNotify(error: error)
            #endif
        }
    }
    
    
    func runBackgroundUpdate(backgroundTask: BGAppRefreshTask) {
        let updateTask = Task(priority: .background) { [weak self] in
            guard let self else { return }
            do {
                #if DEBUG
                didStartNotify()
                #endif
                
                try await self.updateAppFromServerWithError(inBackground: true)
                
                #if DEBUG
                self.completedUpdateNotify(with: nil)
                #endif
                backgroundTask.setTaskCompleted(success: true)
            } catch {
                Global.logger.error("Background update failed with: \(error)")
                self.reportFailure(error)
                #if DEBUG
                self.completedUpdateNotify(with: error)
                #endif
                backgroundTask.setTaskCompleted(success: false)
            }
        }
        
        backgroundTask.expirationHandler = { [weak self] in
            updateTask.cancel()
            self?.scheduleBackgroundUpdate()
            
            #if DEBUG
            self?.completedUpdateNotify(with: IndexUpdateError.unknown("Was cancelled"))
            #endif
        }
     }
    
    func checkServerForUpdate() async {
        serverHasDatabaseUpdate = await checkServerForNewData(inBackground: true) != nil
    }
    
    /// Need to keep in sync with other `updateAppFromServerWithError` callers
    func manualUpdateAppFromServer() async {
        #if DEBUG
        manualUpdateNotify()
        #endif
        
        do {
            try await updateAppFromServerWithError(inBackground: false)
        } catch {
            Global.logger.error("Update failed with: \(error)")
            reportFailure(error)
        }
    }
    
    internal func updateAppFromServerWithError(inBackground: Bool) async throws {
        Global.logger.debug("Starting update request")
        isUpdatingDatabase = true
        
        guard let newData = await checkServerForNewData(inBackground: inBackground) else {
            return
        }
        
        let start = Date()
        Global.logger.debug("Starting update for \(newData.neededCanyonUpdates.count) canyons")
        
        try await canyonManager.updateCanyons(from: newData, inBackground: inBackground)
        
        let durationSeconds = -start.timeIntervalSinceNow
        let duration = DateComponentsFormatter.duration(for: durationSeconds)
        Global.logger.debug("Update for \(newData.neededCanyonUpdates.count) canyons took \(duration)")
        reportSuccess()
    }
    
    /// Whether the shipped, bundled local data is newer than the last time we pulled data from server. If so, preference the newer bundle.
    func checkServerDataAgainstBundle() async {
        if isBundledDataNewerThanUpdates() {
            await canyonManager.clearNetworkUpdate()
            Global.logger.debug("Local bundle is newer than server data. Clearing out server-data.")
        }
    }
    
    private func isBundledDataNewerThanUpdates() -> Bool {
        guard let lastUpdate = statusRecorder.lastUpdate?.time else {
            Global.logger.debug("No last update recorded. Assuming never updated.")
            return false
        }
        return bundledDataUpdatedAt > lastUpdate
    }
    
    internal func shouldAutoCheckForUpdate() -> Bool {
        guard let nextScheduledUpdate else {
            Global.logger.debug("Last update missing or failed, requires checking server for changes.")
            return true
        }
        
        let duration = DateComponentsFormatter.duration(for: abs(nextScheduledUpdate.timeIntervalSinceNow))
        if Date() > nextScheduledUpdate {
            Global.logger.debug("Overdue to check for server changes by \(duration)")
            return true
        } else {
            Global.logger.debug("Next update window in: \(duration)")
            return false
        }
    }
    
    /// Provides information about any server updates since app last checked
    /// - Note; Manages `serverHasDatabaseUpdate` state
    /// - Returns: New updated data (nil if nothing is new or error)
    private func checkServerForNewData(inBackground: Bool) async -> DataUpdate? {
        Global.logger.debug("Checking for update")
        
        guard !inBackground || shouldAutoCheckForUpdate() else {
            Global.logger.debug("Canceling update")
            try? await Task.sleep(for: .seconds(2))
            reportSuccess()
            return nil
        }
        do {
            let newData = try await canyonManager.canyonsRequiringUpdate()
            guard let newData, newData.neededCanyonUpdates.isEmpty == false else {
                Global.logger.debug("No updates required")
                reportSuccess()
                return nil
            }
            serverHasDatabaseUpdate = true
            Global.logger.debug("Server has new updates (\(newData.neededCanyonUpdates.count) canyons)")
            return newData
        } catch {
            Global.logger.error("Failed check for new data on server: \(error)")
            reportFailure(error)
            return nil
        }
    }
    
    private func reportSuccess() {
        updateFailure = nil
        serverHasDatabaseUpdate = false
        statusRecorder.setLastUpdateSuccess()
        isUpdatingDatabase = false
    }
    
    private func reportFailure(_ error: Error) {
        let updateError = (error as? IndexUpdateError) ?? IndexUpdateError.unknown(error.localizedDescription)
        updateFailure = updateError.localizedDescription
        statusRecorder.setLastUpdateFailure(error: updateError)
        isUpdatingDatabase = false
    }
    
    internal enum Constants {
        /// Our key (also in PLIST) for this background update task
        static let appUpdateTaskKey = "backcountry_nomad_canyoneer_index_update"
        
        /// How long between updates from server
        #if DEBUG
        static let updateInterval: Measurement<UnitDuration> = Measurement(value: 1, unit: .hours)
        #else
        static let updateInterval: Measurement<UnitDuration> = Measurement(value: 7 * 24, unit: .hours)
        #endif
    }
}
