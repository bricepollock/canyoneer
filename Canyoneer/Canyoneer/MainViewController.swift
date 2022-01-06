//
//  MainViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationController = UINavigationController(rootViewController: LandingViewController())
        let contained = navigationController
        self.addChild(contained)
        self.view.addSubview(contained.view)
        contained.view.constrain.top(to: self.view, atMargin: true)
        contained.view.constrain.leading(to: self.view)
        contained.view.constrain.trailing(to: self.view)
        contained.view.constrain.bottom(to: self.view, atMargin: true)
        contained.didMove(toParent: self)
    }
}
