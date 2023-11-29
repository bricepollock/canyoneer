//
//  CanyonDetailHeader.swift
//  Canyoneer
//
//  Created by Brice Pollock on 11/29/23.
//

import Foundation
import SwiftUI

struct CanyonDetailHeader: ViewModifier {
    func body(content: Content) -> some View {
        HStack(alignment: .center, spacing: Grid.small) {
            content
            Spacer()
        }
        .padding(.vertical, 2)
        .padding(.horizontal, Grid.xSmall)
        .background(ColorPalette.Color.canyonRed)
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

extension View {
    func asCanyonHeader() -> some View {
        modifier(CanyonDetailHeader())
    }
}
