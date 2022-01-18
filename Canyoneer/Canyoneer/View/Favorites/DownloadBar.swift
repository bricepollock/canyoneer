//
//  DownloadBar.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import UIKit

class DownloadBar: UIView {
    enum Strings {
        static let download = "Downloading: "
    }
    private let masterStack = UIStackView()
    private let header = UILabel()
    private let progress = UIProgressView()
    private let height: CGFloat = 60
    private var heightConstraint: NSLayoutConstraint!
    private var dateShown: Date?
    private var minTimeToShow: Double = 1
    private var isShown: Bool = false
    
    init() {
        super.init(frame: .zero)
        
        self.addSubview(self.masterStack)
        self.masterStack.constrain.fillSuperview(offsets: .init(horizontal: .large, vertical: .zero))
        
        // setup the top stackview
        let placementStack = UIStackView()
        self.masterStack.axis = .horizontal
        self.masterStack.spacing = .medium
        self.masterStack.addArrangedSubview(self.header)
        self.masterStack.addArrangedSubview(placementStack)
        self.header.setContentHuggingPriority(.required, for: .horizontal)
        
        // setup the overall view
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: self.height)
        self.heightConstraint.isActive = true
        self.layer.cornerRadius = height/2
        self.backgroundColor = ColorPalette.GrayScale.light
        
        // setup header
        self.header.text = Strings.download
        
        // setup progress view
        placementStack.axis = .vertical
        placementStack.addArrangedSubview(UIView())
        placementStack.addArrangedSubview(self.progress)
        placementStack.addArrangedSubview(UIView())
        placementStack.alignment = .center
        placementStack.distribution = .equalCentering
        
        let progressHeight: CGFloat = 20
        self.progress.constrain.height(progressHeight)
        self.progress.layer.cornerRadius = progressHeight / 2
        self.progress.clipsToBounds = true
        self.progress.constrain.width(to: self, ratio: 0.5)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(progress: Float) {
        self.progress.setProgress(progress, animated: true)
    }
    
    func hide() {
        guard let dateShown = dateShown else {
            performHide()
            return
        }

        let timeSinceShown = dateShown.timeIntervalSinceNow // a negative number
        let timeRemaing = self.minTimeToShow + timeSinceShown
        guard timeRemaing > 0 else {
            self.performHide()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .seconds(timeRemaing)) {
            self.performHide()
        }
    }
    
    private func performHide() {
        UIView.animate(withDuration: DesignSystem.animation) {
            self.heightConstraint.constant = 0
        } completion: { _ in
            self.isShown = false
            self.isHidden = true
        }
    }
    
    func show() {
        guard isShown == false else { return }
        self.isShown = true
        self.dateShown = Date()
        UIView.animate(withDuration: DesignSystem.animation) {
            self.isHidden = false
            self.heightConstraint.constant = self.height
        }
    }
}
