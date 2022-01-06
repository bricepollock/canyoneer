//
//  FontBook.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

enum FontBook {
    enum Title {
        static let regular = UIFont.systemFont(ofSize: Size.title)
        static let emphasis = UIFont.boldSystemFont(ofSize: Size.title)
    }
    enum Heading {
        static let emphasis = UIFont.boldSystemFont(ofSize: Size.heading)
        static let regular = UIFont.systemFont(ofSize: Size.heading)
    }
    enum Subhead {
        static let emphasis = UIFont.boldSystemFont(ofSize: Size.subhead)
        static let regular = UIFont.systemFont(ofSize:  Size.subhead)
    }
    
    enum Body {
        static let emphasis = UIFont.boldSystemFont(ofSize: Size.body)
        static let regular = UIFont.systemFont(ofSize:  Size.body)
    }
    
    enum Size {
        static let title: CGFloat = 32
        static let heading: CGFloat = 28
        static let subhead: CGFloat = 20
        static let body: CGFloat = 16
    }
}
