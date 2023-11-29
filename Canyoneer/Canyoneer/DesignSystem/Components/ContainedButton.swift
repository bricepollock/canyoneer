//
//  ContainedButton.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import SwiftUI

struct ContainedButtonStyle: ButtonStyle {
    let background = ColorPalette.Color.action
    let textColor = ColorPalette.GrayScale.white
    let selectionColor = ColorPalette.Color.actionDark
    let disabledColor = ColorPalette.Color.actionLight
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 48)
            .frame(minWidth: 232)
            .background(configuration.isPressed ? selectionColor : background)
            .foregroundStyle(textColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// A blue button with white text
struct ContainedButton: View {
    @Environment(\.isEnabled) var isEnabled
    
    let title: String
    let action: () -> Void
    private let style = ContainedButtonStyle()
    
    @ViewBuilder
    var body: some View {
        Button(action: action, label: {
            VStack {
                Spacer()
                Text(title)
                    .font(FontBook.Body.regular)
                    .padding(Grid.small)
                Spacer()
            }
        })
        .frame(maxWidth: .infinity)
        .buttonStyle(style)
        // All other styling done via ButtonStyle
        .background(isEnabled ? style.background :  style.disabledColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
