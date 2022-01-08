//
//  MultiSelectFilter.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/8/22.
//

import Foundation
import UIKit
import MultiSelectSegmentedControl

struct MultiSelectFilterData {
    let name: String
    let selections: [String]
    let initialSelections: [String]
}

class MultiSelectFilter: UIView {
    private let masterStackView = UIStackView()
    private let titleLabel = UILabel()
    private let multiSelectControl = MultiSelectSegmentedControl()
    
    public var selections: [String] {
        return self.multiSelectControl.selectedSegmentTitles
    }
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
        self.masterStackView.axis = .horizontal
        self.masterStackView.spacing = .medium
        
        self.masterStackView.addArrangedSubview(self.titleLabel)
        self.masterStackView.addArrangedSubview(UIView())
        self.masterStackView.addArrangedSubview(self.multiSelectControl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with data: MultiSelectFilterData) {
        self.titleLabel.text = data.name
        self.multiSelectControl.items = data.selections
        let selectedIndices = data.initialSelections.compactMap {
            return data.selections.firstIndex(of: $0)
        }
        self.multiSelectControl.selectedSegmentIndexes = IndexSet(selectedIndices)
    }
}
