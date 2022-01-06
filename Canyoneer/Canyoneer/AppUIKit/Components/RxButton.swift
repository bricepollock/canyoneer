//
//  RxButton.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

public protocol RxButton where Self: UIButton {
    /// The pipe of if the button was selected
    var isSelectedObservable: Observable<Bool> { get }
    
    /// Method to set the title on the view
    func configure(text: String)
}
