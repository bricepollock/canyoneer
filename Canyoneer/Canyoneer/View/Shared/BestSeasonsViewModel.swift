//
//  BestSeasonFilter.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/8/22.
//

import Foundation
import SwiftUI
import Combine

extension Month: Identifiable {
    var id: String {
        self.rawValue
    }
}

@MainActor
class BestSeasonsViewModel: ObservableObject {
    let isUserInteractionEnabled: Bool
        
    @Published private(set) var isAnySelected: Bool
    @Published private(set) var selections: Set<Month>
    private(set) var topRow: [Month] = []
    private(set) var bottomRow: [Month] = []
    
    private var options: [Month] = []
    
    private var bag = Set<AnyCancellable>()
    
    init(
        selections: Set<Month>,
        allOptions: [Month] = Month.allCases, // relying on default sorting
        isUserInteractionEnabled: Bool
    ) {
        self.selections = Set(selections)
        self.isAnySelected = selections.isEmpty == false
        self.isUserInteractionEnabled = isUserInteractionEnabled
        
        // -- init -- //
        
        self.options = allOptions
        
        // show two rows of months because we cannot cramp them all visually into one line
        let mid = options.count / 2
        self.topRow = Array(options.prefix(mid))
        self.bottomRow = Array(options.dropFirst(mid))
        
        self.$selections.sink { [weak self] selections in
            self?.isAnySelected = selections.isEmpty == false
        }.store(in: &bag)
    }
    
    func toggle(for month: Month) {
        let isSelected = !isSelected(month)
        if isSelected {
            selections.insert(month)
        } else {
            selections.remove(month)
        }
    }
    
    func isSelected(_ month: Month) -> Bool {
        selections.contains(month)
    }
    
    func toggleAllSelection() {
        let areAllSelected = !isAnySelected
        selections = areAllSelected ? Set(options) : []
    }
}
