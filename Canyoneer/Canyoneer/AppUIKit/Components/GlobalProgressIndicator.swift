//
//  GlobalProgressIndicator.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit

enum GlobalProgressIndicator {
    
    static private let overview = GlobalProgressViewController()
    
    static func show() {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        UIView.animate(withDuration: DesignSystem.fastAnimation) {
            window?.rootViewController?.view.addSubview(self.overview.view)
            self.overview.view.constrain.fillSuperview()
        }
    }
    
    static func dismiss() {
        UIView.animate(withDuration: DesignSystem.fastAnimation) {
            self.overview.view.removeFromSuperview()
        }
    }
}

class GlobalProgressViewController: UIViewController {
    private let progressIndicator = UIActivityIndicatorView(style: .large)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.15)
        self.view.isOpaque = false
        
        self.view.addSubview(self.progressIndicator)
        self.progressIndicator.constrain.centerX(on: self.view)
        self.progressIndicator.constrain.centerY(on: self.view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.progressIndicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.progressIndicator.stopAnimating()
    }
}
