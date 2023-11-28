//
//  RappelFilterView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/7/22.
//

import Foundation
import UIKit
import Combine

struct SpreadFilterData {
    let name: String
    let units: String?
    let initialMin: Int
    let currentMin: Int
    let initialMax: Int
    let currentMax: Int
    let advanceIncrements: Int
}

class SpreadFilter: UIView {
    
    enum Strings {
        static func spread(maxValue: Int, minValue: Int, units: String?) -> String {
            let prefix = "\(minValue) < \(maxValue)"
            guard let units = units else {
                return prefix
            }
            return prefix + " \(units)"
        }
    }
    
    private let masterStackView = UIStackView()
    private let titleLabel = UILabel()
    private let inputTextControl = CombineUIButton()
    
    public var maxValue: Int = 0
    public var minValue: Int = 0
    
    private var comparisonPicker: ComparisonPicker!
    private var bag = Set<AnyCancellable>()
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(self.masterStackView)
        masterStackView.constrain.fillSuperview()
        masterStackView.axis = .horizontal
        masterStackView.spacing = Grid.xSmall
        
        masterStackView.addArrangedSubview(self.titleLabel)
        masterStackView.addArrangedSubview(UIView())
        masterStackView.addArrangedSubview(self.inputTextControl)
        
        self.titleLabel.font = FontBook.Body.regular
        
        self.inputTextControl.didSelect
            .sink { [weak self] _ in
                guard let self else { return }
                
                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                guard let rootView = window?.rootViewController?.view else { return }

                rootView.addSubview(self.comparisonPicker)
                self.comparisonPicker.constrain.leading(to: rootView)
                self.comparisonPicker.constrain.trailing(to: rootView)
                self.comparisonPicker.constrain.bottom(to: rootView)
                let height = self.comparisonPicker.heightAnchor.constraint(equalToConstant: 0)
                height.isActive = true
                UIView.animate(withDuration: DesignSystem.animation) {
                    self.comparisonPicker.removeConstraint(height)
                }
            }.store(in: &bag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with data: SpreadFilterData) {
        self.minValue = data.currentMin
        self.maxValue = data.currentMax
        
        self.titleLabel.text = data.name
        self.inputTextControl.configure(text: Strings.spread(maxValue: self.maxValue, minValue: self.minValue, units: data.units))
        let pickerData = ComparisonPickerData(
            maxValue: data.initialMax,
            minValue: data.initialMin,
            currentMax: data.currentMax,
            currentMin: data.currentMin,
            advanceIncrements: data.advanceIncrements
        )
        self.comparisonPicker = ComparisonPicker(with: pickerData)
        
        // set initial state
        self.inputTextControl.configure(text: Strings.spread(maxValue: data.currentMax, minValue: data.currentMin, units: data.units))
        
        self.comparisonPicker.$state
            .compactMap { $0 }
            .sink { state in
            self.maxValue = state.max
            self.minValue = state.min
            self.inputTextControl.configure(text: Strings.spread(maxValue: self.maxValue, minValue: self.minValue, units: data.units))
        }.store(in: &bag)
    }
}
