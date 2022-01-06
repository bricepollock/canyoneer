//
//  RegionListRow.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

class RegionListRow: UIView {
    
    public let didSelect: Observable<Void>
    private let didSelectSubject: PublishSubject<Void>
    
    private let name = UILabel()
    private let bag = DisposeBag()
    
    init() {
        self.didSelectSubject = PublishSubject()
        self.didSelect = self.didSelectSubject.asObservable()
        
        super.init(frame: .zero)
        self.addSubview(self.name)
        self.name.constrain.fillSuperview()
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with name: String) {
        self.name.text = name
        self.name.font = FontBook.Body.regular
    }
    
    @objc func didTap() {
        self.didSelectSubject.onNext(())
    }
}
