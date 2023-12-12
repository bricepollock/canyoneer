//  Created by Brice Pollock for Canyoneer on 12/2/23

import Foundation
import SwiftUI
import Lottie

struct MainView: View {
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some View {
        #if TEST
        return EmptyView()
        #endif
        if viewModel.isLoadingApp {
            launchView
            .task { // may need to switch to onappear
                await viewModel.loadApp()
            }
        } else if let tabViewModel = viewModel.tabViewModel {
            MainTabView(viewModel: tabViewModel)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var launchView: some View {
        ZStack {
            Image("img_landing")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .offset(x: -30) // quick hack to match the Launch storyboard which was off for some reason

            LottieView(animation: .named("simple_rap"))
                .resizable()
                .looping()
        }
        .ignoresSafeArea()
    }
}