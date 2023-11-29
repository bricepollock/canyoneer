//
//  ColorPalette.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import SwiftUI

enum ColorPalette {
    enum GrayScale {
        static let black = SwiftUI.Color.black
        static let dark = SwiftUI.Color(uiColor: .darkGray)
        static let gray = SwiftUI.Color.gray
        static let light = SwiftUI.Color(UIColor(white: 0.9, alpha: 1))
        static let white = SwiftUI.Color.white
    }
    
    enum Color {
        static let warning = SwiftUI.Color.red
        static let canyonRed = SwiftUI.Color(uiColor: UIColor(red: 171/255, green: 119/255, blue: 108/255, alpha: 1))
        static let yellow = SwiftUI.Color.yellow
        static let green = SwiftUI.Color.green
        static let action = SwiftUI.Color(uiColor: .systemBlue)
        static let actionDark = SwiftUI.Color.black
        static let actionLight = SwiftUI.Color(uiColor: .lightGray)
    }
}
