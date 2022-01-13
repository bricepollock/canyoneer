//
//  File.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

extension UIView {
    static func createLineView(height: CGFloat = 1) -> UIView {
        let line = UIView()
        line.constrain.height(height)
        line.backgroundColor = ColorPalette.GrayScale.light
        return line
    }
}

