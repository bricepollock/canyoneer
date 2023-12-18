//  Created by Brice Pollock for Canyoneer on 12/2/23

import SwiftUI

@main
struct Canyoneer: App {
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: viewModel)
        }
        // NOTE: BGTask only works on device and not on simulator
        .backgroundTask(.appRefresh(MainViewModel.appUpdateTaskKey)) {
            await viewModel.updateAppFromServer()
        }
    }
}
