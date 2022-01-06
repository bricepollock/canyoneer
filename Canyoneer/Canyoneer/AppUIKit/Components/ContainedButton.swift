//
//  ContainedButton.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

/// A blue button with white text
class ContainedButton: RxUIButton {
    public enum ButtonType {
        case primary
        case secondary
        
        var passiveColor: UIColor {
            switch self {
            case .primary: return ColorPalette.Color.action
            case .secondary: return ColorPalette.GrayScale.white
            }
        }
        
        var selectionColor: UIColor {
            switch self {
            case .primary: return ColorPalette.Color.actionDark
            case .secondary: return ColorPalette.Color.action
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .primary: return ColorPalette.GrayScale.white
            case .secondary: return ColorPalette.GrayScale.black
            }
        }
        
    }
    private enum Constants {
        static let height: CGFloat = 48
        static let padding: CGFloat = Grid.small
        static let standardWidth: CGFloat = 232
    }
    
    private let bag = DisposeBag()
    
    private let textLabel = UILabel()
    
    public init(type: ButtonType = .primary) {
        super.init()
        
        self.isSelectedObservable.subscribeOnNext { [weak self] (isSelected) in
            self?.backgroundColor = isSelected ? type.selectionColor : type.passiveColor
        }.disposed(by: bag)
        
        self.textLabel.textColor = type.textColor
        self.textLabel.isUserInteractionEnabled = false
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 4
        self.addSubview(textLabel)
        
        self.textLabel.constrain.centerY(on: self)
        self.textLabel.constrain.centerX(on: self)
        self.textLabel.constrain.leading(to: self, with: Constants.padding, relation: .greaterThanOrEqual)
        self.textLabel.constrain.top(to: self, with: Constants.padding, relation: .greaterThanOrEqual)
        self.constrain.height(Constants.height)
        
        // Might in the future need different widths or a contentHuggingButton
        self.textLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.constrain.width(Constants.standardWidth, relation: .greaterThanOrEqual)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public override func configure(text: String) {
        self.configure(text: text, font: FontBook.Body.regular)
    }
    
    public func configure(text: String, font: UIFont) {
        self.setTitle(nil, for: .normal)
        self.textLabel.font = font
        self.textLabel.text = text
        self.accessibilityIdentifier = "\(text) button"
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        self.isUserInteractionEnabled = isEnabled
        self.backgroundColor = isEnabled ? ColorPalette.Color.action : ColorPalette.Color.actionLight
    }
}
