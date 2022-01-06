//
//  LandingViewController+textField.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

extension LandingViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        Global.logger.info("input: \(String(describing: textField.text))")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.performSearch(for: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.text != nil else {
            return false
        }
        textField.resignFirstResponder()
        return true
    }
}
