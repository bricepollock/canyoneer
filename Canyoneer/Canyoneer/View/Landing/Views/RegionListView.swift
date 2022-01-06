//
//  RegionListView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

class RegionListRow: UIView {
    private let name = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        self.name.constrain.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with name: String) {
        self.name.text = name
    }
}

struct RegionListViewData {
    let regions: [Region]
}

class RegionListView: UIView {
    let masterStackView = UIStackView()
    
    func configure(with data: RegionListViewData) {
        data.regions.forEach { region in
            let view = RegionListRow()
            view.configure(with: region.name)
            self.masterStackView.addArrangedSubview(view)
        }
    }
}

