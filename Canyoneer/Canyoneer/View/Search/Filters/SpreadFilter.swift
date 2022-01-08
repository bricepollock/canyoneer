//
//  RappelFilterView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/7/22.
//

import Foundation
import UIKit

struct SpreadFilterData {
    let name: String
    let units: String?
    let initialMin: Int
    let initialMax: Int
}

class SpreadFilter: UIView {
    
    enum Strings {
        static let compare = "<"
    }
    
    private let masterStackView = UIStackView()
    private let titleLabel = UILabel()
    private let minTextField = UITextField()
    private let comparisonLabel = UILabel()
    private let maxTextField = UITextField()
    private let unitsLabel = UILabel()
    
    public var maxValue: Int = 0
    public var minValue: Int = 0
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(self.masterStackView)
        masterStackView.constrain.fillSuperview()
        masterStackView.axis = .horizontal
        masterStackView.spacing = Grid.xSmall
        
        masterStackView.addArrangedSubview(self.titleLabel)
        masterStackView.addArrangedSubview(self.minTextField)
        masterStackView.addArrangedSubview(self.comparisonLabel)
        masterStackView.addArrangedSubview(self.maxTextField)
        
        let textFieldWidth: CGFloat = 50
        
        self.titleLabel.font = FontBook.Body.regular
        
        self.minTextField.constrain.width(textFieldWidth)
        
        self.minTextField.keyboardType = .numberPad
        self.minTextField.layer.cornerRadius = DesignSystem.cornerRadius
        self.minTextField.layer.borderColor = ColorPalette.GrayScale.black.cgColor
        self.minTextField.layer.borderWidth = 1
        self.minTextField.textAlignment = .center
        self.minTextField.delegate = self
        
        self.comparisonLabel.font = FontBook.Body.regular
        self.comparisonLabel.text = Strings.compare
        
        self.maxTextField.constrain.width(textFieldWidth)
        self.maxTextField.keyboardType = .numberPad
        self.maxTextField.layer.cornerRadius = DesignSystem.cornerRadius
        self.maxTextField.layer.borderColor = ColorPalette.GrayScale.black.cgColor
        self.maxTextField.layer.borderWidth = 1
        self.maxTextField.textAlignment = .center
        self.maxTextField.delegate = self
        
        self.unitsLabel.font = FontBook.Body.regular
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with data: SpreadFilterData) {
        self.minValue = data.initialMin
        self.maxValue = data.initialMax

        self.titleLabel.text = data.name
        self.minTextField.text = String(data.initialMin)
        self.maxTextField.text = String(data.initialMax)
        self.unitsLabel.text = data.units
        self.unitsLabel.isHidden = data.units == nil
    }
}

extension SpreadFilter: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text, let textInt = Int(text) else { return }
        if textField == self.minTextField {
            self.minValue = textInt
        } else if textField == self.maxTextField {
            self.maxValue = textInt
        }
    }
}
