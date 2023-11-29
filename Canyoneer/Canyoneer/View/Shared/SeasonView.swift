//
//  SeasonView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/9/22.
//

import Foundation
import SwiftUI

class SeasonViewModel: ObservableObject, Identifiable {
    var id: String {
        month.short
    }
    
    @Published private(set) var isSelected: Bool
    let name: String
    
    private let month: Month
    private let isUserInteractionEnabled: Bool
    
    init(month: Month, isSelected: Bool, isUserInteractionEnabled: Bool) {
        self.name = month.short
        self.isSelected = isSelected
        self.month = month
        self.isUserInteractionEnabled = isUserInteractionEnabled
    }
    
    func toggle() {
        update(to: !isSelected)
    }
    
    func update(to isSelected: Bool) {
        guard isUserInteractionEnabled else { return }
        self.isSelected = isSelected
    }
}

struct SeasonView: View {
    @ObservedObject var viewModel: SeasonViewModel
    
    @ViewBuilder
    var body: some View {
        Button(action: {
            viewModel.toggle()
        }, label: {
            Text(viewModel.name)
                .font(FontBook.Body.regular)
                .padding(.vertical, Grid.xSmall)
                .padding(.horizontal, Grid.small)
                .foregroundColor(viewModel.isSelected ? ColorPalette.GrayScale.white : ColorPalette.GrayScale.black)
                .background(viewModel.isSelected ? ColorPalette.Color.action : ColorPalette.GrayScale.white)
                .clipShape(RoundedRectangle(cornerRadius: Constant.corner))
        })
    }
    
    enum Constant {
        static let corner: CGFloat = 10
    }
}
