//
//  UIColor+hex.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import Foundation
import UIKit

// Inspired by https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-hex-color-to-a-uicolor
extension UIColor {
    /// Get the color from a hex value
    /// - Warning: Does not support Alpha, Alpha makes all sorts of unexpected composition
    static func hex(_ hexVal: String) -> UIColor {
        return UIColor(hex: hexVal)!
    }
        
    private convenience init?(hex: String) {
        let r, g, b: CGFloat

        guard hex.hasPrefix("#") else {
            assertionFailure("Missing # in hex")
            return nil
        }
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])

        guard hexColor.count == 6 else {
            assertionFailure("missing expected number of digits")
            return nil
        }
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        guard scanner.scanHexInt64(&hexNumber) else {
            assertionFailure("Cannot scan the number")
            return nil
        }
        r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
        g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
        b = CGFloat((hexNumber & 0x0000ff) >> 0) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
