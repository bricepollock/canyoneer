//
//  ContainedButton.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import SwiftUI

/// A blue button with white text
struct ContainedButton: View {
    private static let background = ColorPalette.Color.action
    private static let textColor = ColorPalette.GrayScale.white
    private static let disabledColor = ColorPalette.Color.actionLight
    
    @Environment(\.isEnabled) var isEnabled
    
    let title: String
    let action: () -> Void
    
    @ViewBuilder
    var body: some View {
        Button(action: action, label: {
            VStack {
                Spacer()
                Text(title)
                    .font(FontBook.Body.regular)
                    .padding(Grid.small)
                    .foregroundStyle(Self.textColor)
                Spacer()
            }
            .frame(height: 48)
            .frame(minWidth: 232)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Self.background :  Self.disabledColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        })
    }
}
