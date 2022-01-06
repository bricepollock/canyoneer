//
//  TagView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

class TagView: UIView {
    private let name = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        self.constrain.height(Grid.large)
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.layer.cornerRadius = Grid.large/2
        
        self.addSubview(self.name)
        self.name.constrain.top(to: self)
        self.name.constrain.leading(to: self, with: Grid.small)
        self.name.constrain.trailing(to: self, with: -Grid.small)
        self.name.constrain.bottom(to: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(name: String, background: UIColor, text: UIColor) {
        self.name.text = name
        self.name.textColor = text
        self.backgroundColor = background
    }
}
