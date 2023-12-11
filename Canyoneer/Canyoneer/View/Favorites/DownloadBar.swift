//
//  DownloadBar.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import SwiftUI


struct DownloadBar: View {
    @Binding var progress: Double
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: Grid.medium) {
                Text(Strings.download)
                    .font(FontBook.Body.regular)
                ProgressView(value: progress)
                    .frame(height: 20)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, Grid.large)
            Spacer()
        }
        .background(ColorPalette.GrayScale.light)
        .frame(height: 60)
        .clipShape(Capsule())
    }
    
    private enum Strings {
        static let download = "Downloading: "
    }
}
