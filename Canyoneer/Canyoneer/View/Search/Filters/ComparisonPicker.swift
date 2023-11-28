//
//  ComparisonPicker.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/9/22.
//

import Foundation
import UIKit

struct ComparisonPickerData {
    let maxValue: Int
    let minValue: Int
    let currentMax: Int
    let currentMin: Int
    let advanceIncrements: Int
}

class ComparisonPicker: UIView {
    enum Strings {
        static let comparison = "<"
        static let done = "Done"
    }
    
    struct State {
        let max: Int
        let min: Int
    }
    
    @Published public var state: State?
    
    private let masterStackView = UIStackView()
    private let toolBar = UIToolbar()
    private let picker = UIPickerView()
    private let comparisonLabel = UILabel()
    
    private let maxValue: Int
    private let minValue: Int
    private let advanceIncrements: Int
    
    private var currentMaxValue: Int
    private var currentMinValue: Int
    
    init(with data: ComparisonPickerData) {
        self.maxValue = data.maxValue
        self.currentMaxValue = data.currentMax
        self.minValue = data.minValue
        self.currentMinValue = data.currentMin
        self.advanceIncrements = data.advanceIncrements
        super.init(frame: .zero)
        self.picker.delegate = self
        self.picker.dataSource = self
        
        // update initial state
        let maxRow = (self.maxValue - self.currentMaxValue) / self.advanceIncrements
        let minRow = self.currentMinValue / self.advanceIncrements
        self.picker.selectRow(minRow, inComponent: 0, animated: false)
        self.picker.selectRow(maxRow, inComponent: 2, animated: false)
        
        self.backgroundColor = ColorPalette.GrayScale.white
        
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
        self.masterStackView.axis = .vertical
        self.masterStackView.addArrangedSubview(self.toolBar)
        self.masterStackView.addArrangedSubview(self.picker)
        
        // toolbar
        self.toolBar.barStyle = UIBarStyle.default
        self.toolBar.isTranslucent = true
        self.toolBar.tintColor = ColorPalette.Color.action

        let doneButton = UIBarButtonItem(title: Strings.done, style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        self.toolBar.setItems([spaceButton, doneButton], animated: false)
        self.toolBar.isUserInteractionEnabled = true
        
        // comparison in picker
        self.comparisonLabel.font = FontBook.Heading.emphasis
        self.comparisonLabel.text = Strings.comparison
        self.picker.addSubview(self.comparisonLabel)
        self.comparisonLabel.constrain.centerX(on: self.picker)
        self.comparisonLabel.constrain.centerY(on: self.picker)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func donePicker() {
        self.resignFirstResponder()
        UIView.animate(withDuration: DesignSystem.animation) {
            self.removeFromSuperview()
        }
    }
}

extension ComparisonPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: self.currentMinValue = (self.minValue + row) * self.advanceIncrements
        case 1: return
        case 2: self.currentMaxValue = (self.maxValue/self.advanceIncrements - row) * self.advanceIncrements
        default: return
        }
        
        self.state = State(max: self.currentMaxValue, min: self.currentMinValue)
    }
}

extension ComparisonPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return (self.maxValue - self.minValue + 1) / advanceIncrements
        case 1: return 0
        case 2: return (self.maxValue - self.minValue + 1) / advanceIncrements
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String((self.minValue + row) * self.advanceIncrements)
        case 1:
            return nil
        case 2:
            return String((self.maxValue/self.advanceIncrements - row) * self.advanceIncrements)
        default:
            return nil
        }
    }
}
