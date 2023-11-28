//
//  LoadingComponent.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import Combine

/// This component bridges the UI and view model implementations to use componententization instead of view controller or view model inheritance
class LoadingComponent {
    public enum LoadingType {
        case inline
        case screen
    }
    
    @Published public var isLoading: Bool = false
    
    /// Add the loading component to the view hiearchy to get inline loading
    public let inlineLoader = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    public init() {
        self.inlineLoader.isHidden = true
        self.inlineLoader.addSubview(self.loadingIndicator)
        self.loadingIndicator.constrain.centerX(on: self.inlineLoader)
        self.loadingIndicator.constrain.top(to: self.inlineLoader)
        self.loadingIndicator.constrain.bottom(to: self.inlineLoader)
    }
    
    public func startLoading(loadingType: LoadingType) {
        switch loadingType {
        case .inline:
            self.inlineLoader.isHidden = false
            self.loadingIndicator.startAnimating()
        case .screen:
            GlobalProgressIndicator.show()
        }
        self.isLoading = true
    }
    
    public func stopLoading() {
        self.loadingIndicator.isHidden = true
        self.loadingIndicator.stopAnimating()
        self.inlineLoader.isHidden = true
        GlobalProgressIndicator.dismiss()
        self.isLoading = false
    }
    
    public func handleError(_ error: Error) {
        Global.logger.error("\(error.localizedDescription)")
        
        let alert = UIAlertController(title: GlobalStrings.networkErrorTitle, message: GlobalStrings.networkErrorDetail, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: GlobalStrings.okay, style: .cancel, handler: nil))
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
