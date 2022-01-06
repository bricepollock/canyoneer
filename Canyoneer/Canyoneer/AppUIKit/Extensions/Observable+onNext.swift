//
//  Observable+onNext.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import RxSwift

extension Observable{
    /// Convience method since subscribe {} fails to understand which closure and subscribe(onNext: ...) requires closures for everything
    func subscribeOnNext(_ closure: @escaping ((Element) -> Void)) -> Disposable {
        return self.subscribe(onNext: closure, onError: nil, onCompleted: nil, onDisposed: nil)
    }
}
