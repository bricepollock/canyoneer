//
//  UIStackView+remove.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

extension UIStackView {
    func removeAll() {
        let views = self.arrangedSubviews
        for view in views {
            self.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
