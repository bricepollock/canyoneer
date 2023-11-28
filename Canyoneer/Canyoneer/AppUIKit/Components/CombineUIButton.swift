//
//  CombineUIButton.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import Combine

/// Reimplement everything in SwiftUI in the future so we can remove this
class CombineUIButton: UIButton {
    /// The button was pressed
    public let didSelect = PassthroughSubject<Void, Never>()
    
    /// Selection state of button
    @Published public var isSelectedState: Bool = false
    
    private var bag = Set<AnyCancellable>()
    
    init(tintColor: UIColor? = nil) {
        super.init(frame: .zero)
        
        // initialize
        self.tintColor = tintColor
        
        // auto update if tint provided
        self.$isSelectedState.sink { [weak self] isSelected in
            self?.tintColor = isSelected ? ColorPalette.Color.actionDark : ColorPalette.Color.action
        }.store(in: &bag)
        
        self.$isSelectedState
            .filter { $0 }
            .sink { [weak self] _ in
                self?.didSelect.send(())
        }.store(in: &bag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(text: String) {
        self.setTitle(text, for: .normal)
    }
    
    public func configure(image: UIImage) {
        self.setImage(image, for: .normal)
        self.contentMode = .scaleAspectFit
    }
    
    private func changeSelection(to selection: Bool) {
        self.isSelected = selection
        self.isSelectedState = selection
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.changeSelection(to: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.changeSelection(to: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.changeSelection(to: false)
    }
}
