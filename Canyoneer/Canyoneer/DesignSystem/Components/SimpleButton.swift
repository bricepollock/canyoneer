//  Created by Brice Pollock for Canyoneer on 11/30/23

import Foundation
import SwiftUI

struct SimpleButtonStyle: ButtonStyle {
    let background = Color.clear
    let textColor = ColorPalette.Color.action
    let selectionColor = ColorPalette.Color.actionDark
    let disabledColor = ColorPalette.GrayScale.gray
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? selectionColor : textColor)
            .background(background)
    }
}

struct SimpleButton: View {
    @Environment(\.isEnabled) var isEnabled
    
    private let title: String
    private let action: () -> Void
    private let style = SimpleButtonStyle()
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    @ViewBuilder
    var body: some View {
        Button(action: action, label: {
            Text(title)
                .font(FontBook.Body.regular)
                .buttonStyle(style)
        })
        .buttonStyle(style)
        // All other styling done via ButtonStyle
        .foregroundColor(isEnabled ? style.textColor :  style.disabledColor)
    }
}
