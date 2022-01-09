//
//  SwitchFilter.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/9/22.
//

import Foundation
import UIKit

class SwitchFilter: UIStackView {
    
    enum Strings {
        static let yes = "Yes"
        static let no = "No"
        static let any = "Any"
    }
    
    private let filterTitle = UILabel()
    private let filterSwitch = UISegmentedControl()
    
    public var selections: [String] {
        switch self.filterSwitch.selectedSegmentIndex {
        case 0: return [Strings.yes]
        case 1: return [Strings.no]
        case 2: return [Strings.any]
        default: return [Strings.any]
        }
    }
    
    public
    
    init() {
        super.init(frame: .zero)
        self.axis = .horizontal
        self.spacing = Grid.medium
        self.addArrangedSubview(self.filterTitle)
        self.addArrangedSubview(UIView())
        self.addArrangedSubview(self.filterSwitch)
        
        self.filterSwitch.insertSegment(withTitle: Strings.yes, at: 0, animated: false)
        self.filterSwitch.insertSegment(withTitle: Strings.no, at: 1, animated: false)
        self.filterSwitch.insertSegment(withTitle: Strings.any, at: 2, animated: false)
        self.filterSwitch.selectedSegmentIndex = 2
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(title: String) {
        self.filterTitle.text = title
    }
}
