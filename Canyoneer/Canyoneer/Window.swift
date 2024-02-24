//  Created by Brice Pollock for Canyoneer on 12/2/23

import SwiftUI

@main
struct Canyoneer: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: viewModel)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:                
                Task(priority: .medium) {
                    await UpdateManager.shared.checkServerForUpdate()
                }                
                break
            case .background:
                // Wasn't able to get background tasks working reliably enough to ship to production
                // https://github.com/bricepollock/canyoneer/issues/29
//                UpdateManager.shared.scheduleBackgroundUpdate()
                break
            default:
                break // no-op
            }
        }
    }
}
