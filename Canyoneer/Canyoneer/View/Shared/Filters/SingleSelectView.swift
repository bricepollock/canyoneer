//  Created by Brice Pollock for Canyoneer on 12/2/23

import Foundation
import SwiftUI

enum BoolChoice: CaseIterable {
    case yes
    case no
    case any
    
    var text: String {
        switch self {
        case .yes: return "Yes"
        case .no: return "No"
        case .any: return "Any"
        }
    }
    
    var value: Bool? {
        switch self {
        case .yes: return true
        case .no: return false
        case .any: return nil
        }
    }
    
    init(_ bool: Bool?) {
        if let bool {
            self = bool ? .yes : .no
        } else {
            self = .any
        }
    }
    
    init?(text: String) {
        guard let found = BoolChoice.allCases.first(where: { $0.text == text }) else {
            return nil
        }
        self = found
    }
}

@MainActor
class SingleSelectViewModel: ObservableObject {
    let choices: [String]
    @Published var selection: String
    
    init(selection: String, choices: [String]) {
        self.selection = selection
        self.choices = choices
    }
    
    convenience init(selection: Bool?) {
        let initial = BoolChoice(selection)
        self.init(
            selection: initial.text,
            choices: BoolChoice.allCases.map { $0.text }
        )
    }
}

struct SingleSelectView: View {
    @ObservedObject var viewModel: SingleSelectViewModel

    @ViewBuilder
    var body: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.choices, id: \.self) { choice in
                if choice != viewModel.choices.first {
                    Divider()
                }
                    
                Button {
                    viewModel.selection = choice
                } label: {
                    Text(choice)
                        .font(FontBook.Body.regular)
                        .foregroundColor(choice == viewModel.selection ? ColorPalette.GrayScale.white : ColorPalette.GrayScale.black )
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(choice == viewModel.selection ? ColorPalette.Color.action : Color.clear )
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .background(.clear)
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
            }
        }
        .background(ColorPalette.GrayScale.light)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
