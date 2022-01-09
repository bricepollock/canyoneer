//
//  ComparisonPicker.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/9/22.
//

import Foundation
import UIKit
import RxSwift

class ComparisonPicker: UIPickerView {
    
    enum Strings {
        static let comparison = "<"
        static let done = "Done"
    }
    
    public let valueChange: Observable<(minValue: Int, maxValue: Int)>
    private let valueChangeSubject: PublishSubject<(minValue: Int, maxValue: Int)>
    
    private let comparisonLabel = UILabel()
    
    private let maxValue: Int
    private let minValue: Int
    private let advanceIncrements: Int
    
    private var currentMaxValue: Int
    private var currentMinValue: Int
    
    init(maxValue: Int, minValue: Int, advanceIncrements: Int) {
        self.maxValue = maxValue
        self.currentMaxValue = maxValue
        self.minValue = minValue
        self.currentMinValue = minValue
        self.advanceIncrements = advanceIncrements
        self.valueChangeSubject = PublishSubject()
        self.valueChange = self.valueChangeSubject.asObservable()
        super.init(frame: .zero)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = ColorPalette.GrayScale.white
        
        self.comparisonLabel.font = FontBook.Heading.emphasis
        self.comparisonLabel.text = Strings.comparison
        self.addSubview(self.comparisonLabel)
        self.comparisonLabel.constrain.centerX(on: self)
        self.comparisonLabel.constrain.centerY(on: self)
        
//        let toolBar = UIToolbar()
//        toolBar.barStyle = UIBarStyle.default
//        toolBar.isTranslucent = true
//        toolBar.tintColor = ColorPalette.Color.action
////        toolBar.sizeToFit()
//
//        let doneButton = UIBarButtonItem(title: Strings.done, style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePicker))
//        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
//
//        toolBar.setItems([spaceButton, doneButton], animated: false)
//        toolBar.isUserInteractionEnabled = true
//        self.addSubview(toolBar)
//        toolBar.constrain.top(to: self)
//        toolBar.constrain.leading(to: self)
//        toolBar.constrain.trailing(to: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func donePicker() {
        self.resignFirstResponder()
        UIView.animate(withDuration: 0.25) {
            self.removeFromSuperview()
        }
    }
}

extension ComparisonPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: self.currentMinValue = (self.minValue + row) * self.advanceIncrements
        case 1: return
        case 2: self.currentMaxValue = (self.minValue + row) * self.advanceIncrements
        default: return
        }
        
        self.valueChangeSubject.onNext((minValue: self.currentMinValue, maxValue: self.currentMaxValue))
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
            return String((self.minValue + row) * self.advanceIncrements)
        default:
            return nil
        }
    }
}
