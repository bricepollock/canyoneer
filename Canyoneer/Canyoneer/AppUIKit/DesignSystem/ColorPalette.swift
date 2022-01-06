//
//  ColorPalette.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

enum ColorPalette {
    enum GrayScale {
        static let black = UIColor.black
        static let dark = UIColor.darkGray
        static let gray = UIColor.gray
        static let light = UIColor.lightGray
        static let white = UIColor.white
    }
    
    enum Color {
        static let red = UIColor.red
        static let yellow = UIColor.yellow
        static let green = UIColor.green
        static let action = UIColor.systemBlue
        static let actionDark = UIColor.black
        static let actionLight = UIColor.lightGray
    }
}
