//
//  ScrollableStackViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

class ScrollableStackViewController: UIViewController {
    public let masterScrollView = UIScrollView()
    public let masterStackView = UIStackView()
    
    private let insets: NSDirectionalEdgeInsets
    private let atMargin: Bool
    
    init(insets: NSDirectionalEdgeInsets = .zero, atMargin: Bool = false) {
        self.insets = insets
        self.atMargin = atMargin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorPalette.GrayScale.white
        
        self.view.addSubview(self.masterScrollView)
        if atMargin {
            self.masterScrollView.constrain.top(to: self.view, atMargin: true)
            self.masterScrollView.constrain.bottom(to: self.view, atMargin: true)
            self.masterScrollView.constrain.leading(to: self.view)
            self.masterScrollView.constrain.trailing(to: self.view)
        } else {
            self.masterScrollView.constrain.fillSuperview()
        }
        
        self.masterScrollView.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview(offsets: insets)
        self.masterStackView.constrain.width(to: self.masterScrollView, with: -insets.leading + insets.trailing)
        self.masterStackView.axis = .vertical
    }
}
