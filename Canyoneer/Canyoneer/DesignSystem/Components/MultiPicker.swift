//  Created by Brice Pollock for Canyoneer on 12/1/23

import SwiftUI

// FIXME: Make this a protocol / generic probably. Conversions are annoying
struct PickerChoice: Hashable, Identifiable {
    var id: String {
        text
    }
    
    let text: String
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(text)
    }
}

@MainActor
class MultiPickerViewModel: ObservableObject {
    enum Component {
        case spread(max: Int, min: Int, step: Int)
        case contains(list: [String])
        
        var choices: [String] {
            switch self {
            case .spread(let max, let min, let step):
                return Array(stride(from: min, to: max, by: step)).map { String($0) }
            case .contains(let list):
                return list
            }
        }
    }
    
    let leftChoices: [PickerChoice]
    let rightChoices: [PickerChoice]
    let seperator: String
    
    @Published var leftValue: PickerChoice
    @Published var rightValue: PickerChoice
    
    init(
        left: Component,
        right: Component,
        seperator: String,
        currentLeft: String,
        currentRight: String
    ) {
        leftChoices = left.choices.map { PickerChoice(text: $0) }
        self.seperator = seperator
        rightChoices = right.choices.map { PickerChoice(text: $0) }
        leftValue = PickerChoice(text: currentLeft)
        rightValue = PickerChoice(text: currentRight)
    }
}

struct MultiPickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MultiPickerViewModel
    
    @ViewBuilder
    var body: some View {
        VStack {
            HStack {
                Spacer()
                SimpleButton(Strings.done) {
                    dismiss()
                }
            }
            HStack {
                Picker(selection: $viewModel.leftValue) {
                    ForEach(viewModel.leftChoices) {
                        Text($0.text)
                            .font(FontBook.Body.regular)
                    }
                } label: {
                    Text("Left --")
                }
                .pickerStyle(.wheel)
                
                Text(viewModel.seperator)
                    .font(FontBook.Heading.emphasis)
                
                
                Picker(selection: $viewModel.rightValue) {
                    ForEach(viewModel.rightChoices) {
                        Text($0.text)
                            .font(FontBook.Body.regular)
                    }
                } label: {
                    Text("Right --")
                }
                .pickerStyle(.wheel)

            }
        }
    }
    
    private enum Strings {
        static let done = "Done"
    }
}
