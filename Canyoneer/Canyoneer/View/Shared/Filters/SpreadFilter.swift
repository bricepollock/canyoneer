//
//  RappelFilterView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/7/22.
//

import Foundation
import SwiftUI

@MainActor
class SpreadFilterViewModel: ObservableObject {
    let name: String
    let units: String?
    let comparisonPicker: ComparisonPickerViewModel
    @Published var actionTitle: String
    
    init(name: String, spreadData: ComparisonPickerData, units: String?) {
        self.name = name
        actionTitle = ""
        self.units = units
        
        comparisonPicker = ComparisonPickerViewModel(configuration: spreadData)
        comparisonPicker.$state.map {
            Strings.spread(maxValue: $0.max, minValue: $0.min, units: units)
        }.assign(to: &$actionTitle)
    }
    
    private enum Strings {
        static func spread(maxValue: Int, minValue: Int, units: String?) -> String {
            let prefix = "\(minValue) < \(maxValue)"
            guard let units = units else {
                return prefix
            }
            return prefix + " \(units)"
        }
    }
}

struct SpreadFilter: View {
    @ObservedObject var viewModel: SpreadFilterViewModel
    
    @State var showPicker: Bool = false
    
    @ViewBuilder
    var body: some View {
        HStack(spacing: Grid.xSmall) {
            Text(viewModel.name)
                .font(FontBook.Body.regular)
            Spacer()
            SimpleButton(viewModel.actionTitle) {
                showPicker = true
            }
        }
        .sheet(isPresented: $showPicker) {
            MultiPickerView(viewModel: viewModel.comparisonPicker.pickerViewModel)
        }
    }
}
