//
//  BestSeasonFilter.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/8/22.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class BestSeasonsViewModel: ObservableObject {
    let isUserInteractionEnabled: Bool
        
    @Published private(set) var isAnySelected: Bool
    @Published private(set) var selections: Set<Month>
    private(set) var topRow: [SeasonViewModel] = []
    private(set) var bottomRow: [SeasonViewModel] = []
    
    private var options: [SeasonViewModel] = []
    
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
        
        self.options = allOptions.map { month in
            let seasonViewModel = SeasonViewModel(
                month: month,
                isSelected: selections.contains(month),
                isUserInteractionEnabled: isUserInteractionEnabled
            )
            seasonViewModel.$isSelected.sink { [weak self] isSelected in
                if isSelected {
                    self?.selections.insert(month)
                } else {
                    self?.selections.remove(month)
                }
            }.store(in: &bag)
            return seasonViewModel
        }
        // show two rows of months because we cannot cramp them all visually into one line
        let mid = options.count / 2
        self.topRow = Array(options.prefix(mid))
        self.bottomRow = Array(options.dropFirst(mid))
        
        self.$selections.sink { [weak self] selections in
            self?.isAnySelected = selections.isEmpty == false
        }.store(in: &bag)
    }
    
    func toggleAllSelection() {
        let areAllSelected = !isAnySelected
        options.forEach {
            $0.update(to: areAllSelected)
        }
    }
}
