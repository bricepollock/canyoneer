//  Created by Brice Pollock for Canyoneer on 2/16/24

import Foundation
import SwiftUI
import Combine

extension Bundle {
    var version: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var build: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var versionBuild: String {
        if let version = Bundle.main.version {
            if let build = Bundle.main.build {
                return "\(version) (\(build))"
            } else {
                return version
            }
        } else {
            return "Unknown"
        }
    }
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var lastSuccessfullyUpdatedAt: String
    /// Only populated if last attempt was unsuccessful
    @Published var lastFailureAttemptAt: String?
    /// Only populated if last attempt was unsuccessful
    @Published var lastUpdateErrorDetails: String?
    @Published var updateButtonText: String = Strings.updateNow
    @Published var updateButtonEnabled: Bool = true
    
    let versionDetails: String
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private let updateManager: UpdateManager
    private var bag = Set<AnyCancellable>()
    
    init(updateManager: UpdateManager, lastUpdateStorage: UserDefaults = UserDefaults.standard) {
        self.updateManager = updateManager
        
        // Initialize from system
        if let lastSuccessDate = lastUpdateStorage.lastSuccessfulUpdate {
            self.lastSuccessfullyUpdatedAt = dateFormatter.string(from: lastSuccessDate)
        } else {
            self.lastSuccessfullyUpdatedAt = Strings.appInstall
        }
        versionDetails = Bundle.main.versionBuild
        
        // Update from saved state
        if let lastUpdate = lastUpdateStorage.lastUpdate {
            self.update(with: lastUpdate)
        }
        
        // Update dynamically
        updateManager.$serverHasDatabaseUpdate
            .combineLatest(updateManager.$isUpdatingDatabase)
            .map { hasUpdate, isUpdating in
                if isUpdating {
                    return Strings.updating
                } else if hasUpdate {
                    return Strings.updateAvailable
                } else {
                    return Strings.updateNow
                }
            }
            .assign(to: &$updateButtonText)
        
        // Button disabled while updating
        updateManager.$isUpdatingDatabase
            .map { !$0 }
            .assign(to: &$updateButtonEnabled)
        
        // Manual update always triggers this, even if we don't hit server
        updateManager.$isUpdatingDatabase
            .dropFirst()
            .filter { !$0 } // when we are done, update
            .compactMap { _ in lastUpdateStorage.lastUpdate } // get the last update result
            .sink { [weak self] lastUpdate in
                self?.update(with: lastUpdate)
            }.store(in: &bag)
    }
    
    func willAppear() async {
        await updateManager.checkServerForUpdate()
    }
    
    func manuallyUpdate() async {
        await updateManager.manualUpdateAppFromServer()
    }
    
    private func update(with lastUpdate: IndexUpdate) {
        switch lastUpdate.status {
        case .success:
            self.lastSuccessfullyUpdatedAt = dateFormatter.string(from: lastUpdate.time)
            self.lastFailureAttemptAt = nil
            self.lastUpdateErrorDetails = nil
        case .failure(let failure):
            self.lastFailureAttemptAt = dateFormatter.string(from: lastUpdate.time)
            #if DEBUG
            self.lastUpdateErrorDetails = failure.debugDetails
            #else
            self.lastUpdateErrorDetails = failure.humanMessage
            #endif
        }
    }
    
    private enum Strings {
        static let appInstall = "App Install"
        static let updateNow = "Update Now"
        static let updateAvailable = "Update Available"
        static let updating = "Updating..."
    }
}
