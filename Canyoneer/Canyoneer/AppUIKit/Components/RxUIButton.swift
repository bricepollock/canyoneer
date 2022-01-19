//
//  RxUIButton.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

/// [bpollock] I really, really didn't want to create this class, but the interface exposed is garbage for watching selection state
/// The RxSwift implementors see no issue, but have they ever tried to observe selectable?
class RxUIButton: UIButton, RxButton {
    
    // these observables are called dynamically as button is pressed
    public let didSelect: Observable<Void>
    public let didSelectSubject: PublishSubject<Void>
    
    // these observables provided the current selection value
    public let isSelectedObservable: Observable<Bool>
    private let isSelectedSubject: BehaviorSubject<Bool>
    
    private let bag = DisposeBag()
    
    init(tintColor: UIColor? = nil) {
        self.isSelectedSubject = BehaviorSubject(value: false)
        self.isSelectedObservable = self.isSelectedSubject.asObservable()
        self.didSelectSubject = PublishSubject()
        self.didSelect = self.didSelectSubject.asObservable()
        super.init(frame: .zero)
        
        // initialize
        self.tintColor = tintColor
        
        // auto update if tint provided
        self.isSelectedObservable.subscribeOnNext { (isSelected) in
            self.tintColor = isSelected ? ColorPalette.Color.actionDark : ColorPalette.Color.action
        }.disposed(by: self.bag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(text: String) {
        self.setTitle(text, for: .normal)
    }
    
    public func configure(image: UIImage) {
        self.setImage(image, for: .normal)
    }
    
    private func changeSelection(to selection: Bool) {
        self.isSelected = selection
        self.isSelectedSubject.onNext(selection)
        
        if selection == true {
            self.didSelectSubject.onNext(())
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.changeSelection(to: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.changeSelection(to: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.changeSelection(to: false)
    }
}
