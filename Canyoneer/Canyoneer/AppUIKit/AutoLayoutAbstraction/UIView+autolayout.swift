//
//  AutoLayout+helpers.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

/// This is a very light abstraction around autolayout to improve readability in code to make things more streamlined
/// Also provides convenience functions for things like filling superview
public extension UIView {
    var constrain: ConstraintEngine {
        return ConstraintEngine(with: self)
    }
    
    struct ConstraintEngine {
        weak var this: UIView?
        fileprivate init(with view: UIView) {
            self.this = view
        }
        
        // MARK: Boundary Pinning
        
        public func leading(to view: UIView, with constant: CGFloat = 0.0, relation: NSLayoutConstraint.Relation = .equal) {
            self.applyAnchor(self.this?.leadingAnchor, and: view.leadingAnchor, with: constant, relation: relation)
        }
        
        public func trailing(to view: UIView, with constant: CGFloat = 0.0, relation: NSLayoutConstraint.Relation = .equal) {
            self.applyAnchor(self.this?.trailingAnchor, and: view.trailingAnchor, with: constant, relation: relation)
        }
        
        public func top(to view: UIView, atMargin: Bool = false, with constant: CGFloat = 0.0, relation: NSLayoutConstraint.Relation = .equal) {
            let anchor: NSLayoutYAxisAnchor
            if atMargin {
                anchor = view.layoutMarginsGuide.topAnchor
            } else {
                anchor = view.topAnchor
            }
            self.applyAnchor(self.this?.topAnchor, and: anchor, with: constant, relation: relation)
        }
        
        public func bottom(to view: UIView, atMargin: Bool = false, with constant: CGFloat = 0.0, relation: NSLayoutConstraint.Relation = .equal) {
            let anchor: NSLayoutYAxisAnchor
            if atMargin {
                anchor = view.layoutMarginsGuide.bottomAnchor
            } else {
                anchor = view.bottomAnchor
            }
            self.applyAnchor(self.this?.bottomAnchor, and: anchor, with: constant, relation: relation)
        }
        
        public func horizontalSpacing(to view: UIView, with constant: CGFloat = 0.0, relation: NSLayoutConstraint.Relation = .equal) {
            self.applyAnchor(self.this?.leadingAnchor, and: view.trailingAnchor, with: constant, relation: relation)
        }
        
        public func verticalSpacing(to view: UIView, with constant: CGFloat = 0.0, relation: NSLayoutConstraint.Relation = .equal) {
            self.applyAnchor(self.this?.topAnchor, and: view.bottomAnchor, with: constant, relation: relation)
        }
        
        public func fillView(_ view: UIView, offsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(all: 0.0)) {
            self.top(to: view, with: offsets.top)
            self.bottom(to: view, with: offsets.bottom)
            self.leading(to: view, with: offsets.leading)
            self.trailing(to: view, with: offsets.trailing)
        }
        
        public func fillSuperview(offsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(all: 0.0)) {
            guard let parent = self.this?.superview else {
                
                Global.logger.debug("No superview found!")
                return
            }
            self.fillView(parent, offsets: offsets)
        }
        
        // MARK: Relational
        
        public func centerY(on view: UIView, with offset: CGFloat = 0) {
            self.applyAnchor(self.this?.centerYAnchor, and: view.centerYAnchor, with: offset, relation: .equal)
        }
        
        public func centerX(on view: UIView, with offset: CGFloat = 0) {
            self.applyAnchor(self.this?.centerXAnchor, and: view.centerXAnchor, with: offset, relation: .equal)
        }
        
        public func height(to view: UIView, ratio: CGFloat = 1, with offset: CGFloat = 0) {
            self.setupForAutoLayout()
            self.this?.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: ratio, constant: offset).isActive = true
        }
        
        public func width(to view: UIView, ratio: CGFloat = 1, with offset: CGFloat = 0) {
            self.setupForAutoLayout()
            self.this?.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: ratio, constant: offset).isActive = true
        }
        
        // MARK: Self Constraints
        
        public func height(_ height: CGFloat, relation: NSLayoutConstraint.Relation = .equal) {
            self.setupForAutoLayout()
            
            switch relation {
            case .equal:
                self.this?.heightAnchor.constraint(equalToConstant: height).isActive = true
            case .greaterThanOrEqual:
                self.this?.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
            case .lessThanOrEqual:
                self.this?.heightAnchor.constraint(lessThanOrEqualToConstant: height).isActive = true
            @unknown default:
                self.this?.heightAnchor.constraint(equalToConstant: height).isActive = true
            }
        }
        
        public func width(_ width: CGFloat, relation: NSLayoutConstraint.Relation = .equal) {
            self.setupForAutoLayout()
            
            switch relation {
            case .equal:
                self.this?.widthAnchor.constraint(equalToConstant: width).isActive = true
            case .greaterThanOrEqual:
                self.this?.widthAnchor.constraint(greaterThanOrEqualToConstant: width).isActive = true
            case .lessThanOrEqual:
                self.this?.widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
            @unknown default:
                self.this?.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
        }
        
        public func aspect(_ ratio: CGFloat) {
            self.setupForAutoLayout()
            guard let this = self.this else {
                Global.logger.debug("Self view was released")
                return
            }
            this.widthAnchor.constraint(equalTo: this.heightAnchor, multiplier: ratio).isActive = true
        }
        
        // MARK: Private functions
        
        private func applyAnchor<T: AnyObject>(
            _ thisAnchor: NSLayoutAnchor<T>?,
            and thatAnchor: NSLayoutAnchor<T>,
            with constant: CGFloat,
            relation: NSLayoutConstraint.Relation) {
            
            guard let thisAnchor = thisAnchor else {
                Global.logger.debug("Self view was released")
                return
            }
            self.setupForAutoLayout()
            
            switch relation {
            case .equal:
                thisAnchor.constraint(equalTo: thatAnchor, constant: constant).isActive = true
            case .greaterThanOrEqual:
                thisAnchor.constraint(greaterThanOrEqualTo: thatAnchor, constant: constant).isActive = true
            case .lessThanOrEqual:
                thisAnchor.constraint(lessThanOrEqualTo: thatAnchor, constant: constant).isActive = true
            @unknown default:
                thisAnchor.constraint(equalTo: thatAnchor, constant: constant).isActive = true
            }
        }
        
        private func setupForAutoLayout() {
            self.this?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
