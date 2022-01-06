//
//  GlobalSearchView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

class GlobalSearchView: UIView {
    enum Strings {
        static let title = "Search"
    }
    
    private let masterStackView = UIStackView()
    private let titleLabel = UILabel()
    public let searchTextField = UITextField()
    private let searchButton = ContainedButton()
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
        self.masterStackView.axis = .horizontal
        self.masterStackView.spacing = Grid.small
        
        self.masterStackView.addArrangedSubview(self.titleLabel)
        self.masterStackView.addArrangedSubview(self.searchTextField)
        
        self.titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.titleLabel.text = Strings.title
        
        self.searchTextField.layer.cornerRadius = DesignSystem.cornerRadius
        self.searchTextField.layer.borderColor = ColorPalette.GrayScale.black.cgColor
        self.searchTextField.layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: Respond to text input
}

