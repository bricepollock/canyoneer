//
//  SeasonView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/9/22.
//

import Foundation
import UIKit
import Combine

class SeasonView: UIView {
    
    @Published public var isSelected: Bool
    
    public let didSelect = PassthroughSubject<Void, Never>()
    
    private let month = UILabel()
    private let size: CGFloat = 20
    private let selectionColor = ColorPalette.Color.action
    
    var text: String? {
        return month.text
    }
    
    init() {
        self.isSelected = false
        super.init(frame: .zero)
        self.layer.cornerRadius = self.size / 2
        self.addSubview(self.month)
        self.month.constrain.fillSuperview(offsets: .init(all: .xSmall))
        self.month.font = FontBook.Body.regular
        self.chooseSelection(self.isSelected)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func chooseSelection(_ isSelected: Bool) {
        self.isSelected = isSelected
        self.backgroundColor = isSelected ? selectionColor : ColorPalette.GrayScale.white
        self.month.textColor = isSelected ? ColorPalette.GrayScale.white : ColorPalette.GrayScale.black
    }
    
    public func configure(name: String) {
        self.month.text = name
    }
    
    @objc func didTap() {
        self.chooseSelection(!isSelected)
        self.didSelect.send()
    }
}
