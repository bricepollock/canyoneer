//
//  ComparisonPicker.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/9/22.
//

import Foundation
import SwiftUI

struct Bounds {
    let min: Int
    let max: Int
}

struct ComparisonPickerData {
    let current: Bounds
    let limits: Bounds
    let increments: Int
}

@MainActor
class ComparisonPickerViewModel: ObservableObject {
    @Published var state: Bounds
    let pickerViewModel: MultiPickerViewModel
    
    init(configuration: ComparisonPickerData) {
        pickerViewModel = MultiPickerViewModel(
            left: .spread(max: configuration.limits.min, min: configuration.limits.max, step: configuration.increments),
            right: .spread(max: configuration.limits.min, min: configuration.limits.max, step: configuration.increments),
            seperator: Strings.comparison,
            currentLeft: String(configuration.current.min),
            currentRight: String(configuration.current.max)
        )
        self.state = configuration.current
        pickerViewModel.$leftValue.combineLatest(pickerViewModel.$rightValue).map { left, right in
            Bounds(min: Int(left.text) ?? configuration.current.min, max: Int(right.text) ?? configuration.current.max)
        }.assign(to: &$state)
    }

    private enum Strings {
        static let comparison = "<"
    }
}
