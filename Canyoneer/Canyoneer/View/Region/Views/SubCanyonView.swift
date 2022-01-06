//
//  SubCanyonView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

class SubCanyonView: UIView {
    enum Strings {
        static func name(with name: String) -> String {
            return "\(name)"
        }
    }
    
    public let didSelect: Observable<Void>
    private let didSelectSubject: PublishSubject<Void>

    private let name = UILabel()
    
    init() {
        self.didSelectSubject = PublishSubject()
        self.didSelect = self.didSelectSubject.asObservable()
        
        super.init(frame: .zero)
        self.addSubview(self.name)
        self.name.constrain.fillSuperview()
        self.name.font = FontBook.Body.regular
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with name: String) {
        self.name.text = Strings.name(with: name)
    }
    
    @objc func didTap() {
        self.didSelectSubject.onNext(())
    }
}
