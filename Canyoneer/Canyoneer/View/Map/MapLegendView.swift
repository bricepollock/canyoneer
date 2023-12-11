//
//  MapLegendBottomSheetViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import SwiftUI

struct MapLegendView: View {
    @ViewBuilder
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(Strings.title)
                    .font(FontBook.Subhead.regular)
                Spacer()
            }
            legendItem(title: Strings.driving, color: TopoLineType.driving.color)
            legendItem(title: Strings.approach, color: TopoLineType.approach.color)
            legendItem(title: Strings.descent, color: TopoLineType.descent.color)
            legendItem(title: Strings.exit, color: TopoLineType.exit.color)
            legendItem(title: Strings.other, color: TopoLineType.unknown.color)
        }
        .padding(Grid.medium)
        .presentationDetents([.height(220)])
    }
    
    @ViewBuilder
    func legendItem(title: String, color: Color) -> some View {
        HStack(alignment: .center, spacing: Grid.medium) {
            Text(title)
                .font(FontBook.Body.regular)
            Spacer()
            Rectangle()
                .fill(color)
                .frame(width: Constants.lineLength, height: Constants.lineWidth)                
        }
    }
    
    private enum Constants {
        static let lineWidth: CGFloat = 10
        static let lineLength: CGFloat = 50
    }
    
    private enum Strings {
        static let title = "Legend"
        static let driving = "Driving/Shuttle"
        static let exit = "Exit"
        static let approach = "Approach"
        static let descent = "Descent"
        static let other = "Unclassified (See Canyon Map)"
    }
}
