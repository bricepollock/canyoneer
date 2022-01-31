//
//  MainViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift
import Lottie

class MainViewController: UIViewController {
    private let canyonService = RopeWikiService()
    private let bag = DisposeBag()
    private let background = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // mirror launch screen
        self.view.addSubview(self.background)
        self.background.constrain.fillSuperview()
        background.image = UIImage(named: "img_landing")
        background.contentMode = .scaleAspectFill
    
        // add animation
        let animation = Animation.named("simple_rap")
        let animationView = AnimationView(animation: animation)
        animationView.contentMode = .scaleAspectFill
        
        // add animation to view
        self.view.addSubview(animationView)
        animationView.constrain.trailing(to: self.view)
        animationView.constrain.width(to: self.view)
        animationView.constrain.top(to: self.view)
        animationView.constrain.bottom(to: self.view)
        animationView.play(toProgress: 1, loopMode: .loop)
        
        // load the canyon data
        DispatchQueue.global().async {
            self.canyonService.canyons().subscribe { _ in
                DispatchQueue.main.async {
                    animationView.stop()
                    animationView.removeFromSuperview()
                    self.launchApp()
                }
            } onFailure: { error in
                DispatchQueue.main.async {
                    animationView.stop()
                    animationView.removeFromSuperview()
                    self.launchApp()
                }
                Global.logger.error(error)
            }.disposed(by: self.bag)
        }
    }
    
    private func launchApp() {
        self.background.removeFromSuperview()
        
        let contained = MainTabBarController.make()
        self.addChild(contained)
        self.view.addSubview(contained.view)
        contained.view.constrain.top(to: self.view, atMargin: true)
        contained.view.constrain.leading(to: self.view)
        contained.view.constrain.trailing(to: self.view)
        contained.view.constrain.bottom(to: self.view, atMargin: false)
        contained.didMove(toParent: self)        
    }
}
