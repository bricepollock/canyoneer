//
//  UIEdgeInsets+Extensions.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import UIKit

extension UIEdgeInsets {
    public init(all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }
    
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: -vertical, right: -horizontal)
    }
}
