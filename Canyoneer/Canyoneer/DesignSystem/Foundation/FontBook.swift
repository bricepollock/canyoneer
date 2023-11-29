//
//  FontBook.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import SwiftUI

enum FontBook {
    enum Title {
        static let regular = Font.system(size: Size.title)
        static let emphasis = Font.system(size: Size.title, weight: .bold)
    }
    enum Heading {
        static let emphasis = Font.system(size: Size.heading, weight: .bold)
        static let regular = Font.system(size: Size.heading)
    }
    enum Subhead {
        static let emphasis = Font.system(size: Size.subhead, weight: .bold)
        static let regular = Font.system(size:  Size.subhead)
    }
    
    enum Body {
        static let emphasis = Font.system(size: Size.body, weight: .bold)
        static let regular = Font.system(size:  Size.body)
    }
    
    enum Size {
        static let title: CGFloat = 32
        static let heading: CGFloat = 28
        static let subhead: CGFloat = 20
        static let body: CGFloat = 16
    }
}
