//
//  SubRegionView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

class SubRegionView: UIView {
    enum Strings {
        static func name(with name: String) -> String {
            return "\t* \(name)"
        }
    }
    private let name = UILabel()
    
    init() {
        super.init(frame: .zero)
        self.addSubview(self.name)
        self.name.constrain.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with name: String) {
        self.name.text = Strings.name(with: name)
    }
}

class SubRegionListView: UIView {
    
    enum Strings {
        static let title = "Sub Regions:"
    }
    
    private let titleLabel = UILabel()
    private let regionStack = UIStackView()
    
    init() {
        super.init(frame: .zero)
        self.addSubview(self.regionStack)
        self.regionStack.constrain.fillSuperview()
        self.regionStack.spacing = .medium
        self.regionStack.axis = .vertical
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with regions: [Region]) {
        self.regionStack.removeAll()
        
        self.titleLabel.text = Strings.title
        self.regionStack.addArrangedSubview(self.titleLabel)
                
        regions.forEach {
            let view = SubRegionView()
            view.configure(with: $0.name)
            self.regionStack.addArrangedSubview(view)
        }
    }
}
