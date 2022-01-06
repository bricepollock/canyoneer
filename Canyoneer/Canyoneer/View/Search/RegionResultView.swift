//
//  RegionResultView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

class RegionResultView: UIView {
    
    enum Strings {
        static func name(with name: String) -> String {
            return "\(name) (region)"
        }
        static func childrenCount(count: Int) -> String {
            return "\(count) subareas"
        }
    }
    
    private let masterStackView = UIStackView()
    // RHS details
    private let detailStackView = UIStackView()
    
    private let name = UILabel()
    private let childrenCount = UILabel()
    
    init() {
        super.init(frame: .zero)
    
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
        
        self.masterStackView.axis = .horizontal
        self.masterStackView.spacing = Grid.medium
        self.masterStackView.addArrangedSubview(self.name)
        self.masterStackView.addArrangedSubview(self.detailStackView)
        
        self.detailStackView.axis = .vertical
        self.detailStackView.spacing = Grid.medium
        self.detailStackView.addArrangedSubview(self.childrenCount)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with result: SearchResult) {
        guard let region = result.regionDetails else {
            return
        }
        
        self.name.text = Strings.name(with: region.name)
        self.childrenCount.text = Strings.childrenCount(count: region.children.count)
    }
}
