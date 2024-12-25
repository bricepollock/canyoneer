//  Created by Brice Pollock for Canyoneer on 12/25/24

import SwiftUI

extension View {
    public func border(color: Color, width: CGFloat = 1, cornerRadius: CGFloat) -> some View {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(color, lineWidth: width))
    }
}
