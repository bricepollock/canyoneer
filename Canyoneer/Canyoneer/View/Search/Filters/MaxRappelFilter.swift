//
//  RappelFilterView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/7/22.
//

import Foundation
import UIKit

class MaxRappelFilter: UIView {
    
    enum Strings {
        static let title = "Max Rappel"
        static let compare = "<"
        static let units = "ft"
    }
    
    private let masterStackView = UIStackView()
    private let titleLabel = UILabel()
    private let minRapTextField = UITextField()
    private let comparisonLabel = UILabel()
    private let maxRapTextField = UITextField()
    private let unitsLabel = UILabel()
    
    public var minRappels: Int = 0
    public var maxRappels: Int = 500
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(self.masterStackView)
        masterStackView.constrain.fillSuperview()
        masterStackView.axis = .horizontal
        masterStackView.spacing = Grid.xSmall
        
        masterStackView.addArrangedSubview(self.titleLabel)
        masterStackView.addArrangedSubview(self.minRapTextField)
        masterStackView.addArrangedSubview(self.comparisonLabel)
        masterStackView.addArrangedSubview(self.maxRapTextField)
        
        let textFieldWidth: CGFloat = 50
        
        self.titleLabel.font = FontBook.Body.regular
        self.titleLabel.text = Strings.title
        
        self.minRapTextField.constrain.width(textFieldWidth)
        self.minRapTextField.text = String(self.minRappels)
        self.minRapTextField.keyboardType = .numberPad
        self.minRapTextField.layer.cornerRadius = DesignSystem.cornerRadius
        self.minRapTextField.layer.borderColor = ColorPalette.GrayScale.black.cgColor
        self.minRapTextField.layer.borderWidth = 1
        self.minRapTextField.textAlignment = .center
        self.minRapTextField.delegate = self
        
        self.comparisonLabel.font = FontBook.Body.regular
        self.comparisonLabel.text = Strings.compare
        
        self.maxRapTextField.constrain.width(textFieldWidth)
        self.maxRapTextField.text = String(self.maxRappels)
        self.maxRapTextField.keyboardType = .numberPad
        self.maxRapTextField.layer.cornerRadius = DesignSystem.cornerRadius
        self.maxRapTextField.layer.borderColor = ColorPalette.GrayScale.black.cgColor
        self.maxRapTextField.layer.borderWidth = 1
        self.maxRapTextField.textAlignment = .center
        self.maxRapTextField.delegate = self
        
        self.unitsLabel.text = Strings.units
        self.unitsLabel.font = FontBook.Body.regular
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MaxRappelFilter: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text, let textInt = Int(text) else { return }
        if textField == self.minRapTextField {
            self.minRappels = textInt
        } else if textField == self.maxRapTextField {
            self.maxRappels = textInt
        }
    }
}
