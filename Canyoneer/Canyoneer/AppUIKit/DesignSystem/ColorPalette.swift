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
        static let light = UIColor(white: 0.9, alpha: 1)
        static let white = UIColor.white
    }
    
    enum Color {
        static let warning = UIColor.red
        static let canyonRed = UIColor(red: 171/255, green: 119/255, blue: 108/255, alpha: 1)
        static let yellow = UIColor.yellow
        static let green = UIColor.green
        static let action = UIColor.systemBlue
        static let actionDark = UIColor.black
        static let actionLight = UIColor.lightGray
    }
}
