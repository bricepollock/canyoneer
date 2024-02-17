//  Created by Brice Pollock for Canyoneer on 2/16/24

import Foundation
import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
        
    var body: some View {
        VStack(alignment: .leading, spacing: Grid.small) {
            dataRow(title: Strings.lastSuccessTitle, detail: viewModel.lastSuccessfullyUpdatedAt)
            if let errorTime = viewModel.lastFailureAttemptAt {
                dataRow(title: Strings.lastFailedTitle, detail: errorTime)
            }
            if let errorString = viewModel.lastUpdateErrorDetails {
                ScrollView {
                    HStack {
                        Text(errorString)
                            .font(FontBook.Body.emphasis)
                            .foregroundColor(ColorPalette.Color.warning)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
            }
            
            ContainedButton(title: viewModel.updateButtonText) {
                Task(priority: .userInitiated) {
                    await viewModel.manuallyUpdate()
                }
            }
            .padding(.top, Grid.medium)
            .disabled(!viewModel.updateButtonEnabled)
            
            Spacer()
            
            HStack {
                Spacer()
                Text(viewModel.versionDetails)
                    .font(FontBook.Body.regular)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
        .navigationTitle(Strings.title)
        .padding(.horizontal, Grid.medium)
        .padding(.top, Grid.large)
        .padding(.bottom, Grid.xLarge)
        .task {
            await viewModel.willAppear()
        }
    }
    
    @ViewBuilder
    private func dataRow(title: String, detail: String) -> some View {
        HStack {
            Text(title)
                .font(FontBook.Body.emphasis)
            Text(detail)
                .font(FontBook.Body.regular)
            Spacer()
        }
    }
    
    private enum Strings {
        static let title = "App Details"
        static let lastSuccessTitle = "Last Update:"
        static let lastFailedTitle = "Recent Failure:"
    }
}
