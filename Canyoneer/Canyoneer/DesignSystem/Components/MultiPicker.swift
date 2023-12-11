//  Created by Brice Pollock for Canyoneer on 12/1/23

import SwiftUI

@MainActor
class MultiPickerViewModel: ObservableObject {
    enum Component {
        case spread(max: Int, min: Int, step: Int)
        case contains(list: [String])
        
        var choices: [String] {
            switch self {
            case .spread(let max, let min, let step):
                let end = max + step // we want to include the max
                return Array(stride(from: min, to: end, by: step)).map { String($0) }
            case .contains(let list):
                return list
            }
        }
    }
    
    let leftChoices: [String]
    let rightChoices: [String]
    let seperator: String
    
    @Published var leftValue: String
    @Published var rightValue: String
    
    init(
        left: Component,
        right: Component,
        seperator: String,
        currentLeft: String,
        currentRight: String
    ) {
        leftChoices = left.choices
        self.seperator = seperator
        rightChoices = right.choices
        leftValue = currentLeft
        rightValue = currentRight
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
            HStack(alignment: .center) {
                Picker("", selection: $viewModel.leftValue) {
                    ForEach(viewModel.leftChoices, id: \.self) {
                        Text($0)
                            .font(FontBook.Body.regular)
                    }
                }
                .pickerStyle(.wheel)
                
                Text(viewModel.seperator)
                    .font(FontBook.Heading.regular)
                
                Picker("", selection: $viewModel.rightValue) {
                    ForEach(viewModel.rightChoices, id: \.self) {
                        Text($0)
                            .font(FontBook.Body.regular)
                    }
                }
                .pickerStyle(.wheel)
            }
        }
        .padding(Grid.medium)
        .presentationDetents([.height(280)])
    }
    
    private enum Strings {
        static let done = "Done"
    }
}
