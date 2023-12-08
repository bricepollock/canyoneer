//
//  MultiSelectFilter.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/8/22.
//

import Foundation
import SwiftUI

@MainActor
class MultiSelectViewModel: ObservableObject {
    let choices: [String]
    @Published var selections: Set<String>
    
    init(selections: Set<String>, choices: [String]) {
        self.selections = selections
        self.choices = choices
    }
    
    func isSelected(_ choice: String) -> Bool {
        selections.contains(choice)
    }
    
    func toggle(_ choice: String) {
        if isSelected(choice) {
            selections.remove(choice)
        } else {
            selections.insert(choice)
        }
    }
}

struct MultiSelectView: View {
    @ObservedObject var viewModel: MultiSelectViewModel

    @ViewBuilder
    var body: some View {
        HStack(spacing: 1) {
            ForEach(viewModel.choices, id: \.self) { choice in
                Button(action: {
                    viewModel.toggle(choice)
                }, label: {
                    Text(choice)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .foregroundStyle(viewModel.isSelected(choice) ? ColorPalette.GrayScale.white : ColorPalette.Color.action)
                        .background(viewModel.isSelected(choice) ? ColorPalette.Color.action : ColorPalette.GrayScale.white)                        
                })

            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
