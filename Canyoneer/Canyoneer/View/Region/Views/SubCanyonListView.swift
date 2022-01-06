//
//  SubCanyonListView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

class SubCanyonListView: UIView {
    enum Strings {
        static func title(with canyons: [Canyon]) -> String {
            let base = " Canyons"
            guard !canyons.isEmpty else {
                return "\(base) (None)"
            }
            return base
        }
    }
    public let didSelect: Observable<Canyon>
    private let didSelectSubject: PublishSubject<Canyon>
    
    private let bag = DisposeBag()
    
    private let titleLabel = UILabel()
    private let canyonStack = UIStackView()
    
    init() {
        self.didSelectSubject = PublishSubject()
        self.didSelect = self.didSelectSubject.asObservable()

        super.init(frame: .zero)
        self.addSubview(self.canyonStack)
        self.canyonStack.constrain.fillSuperview()
        self.canyonStack.spacing = .xSmall
        self.canyonStack.axis = .vertical
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with canyons: [Canyon]) {
        self.canyonStack.removeAll()
        
        self.titleLabel.text = Strings.title(with: canyons)
        self.titleLabel.backgroundColor = ColorPalette.Color.canyonRed
        self.titleLabel.font = FontBook.Body.emphasis
        
        self.canyonStack.addArrangedSubview(self.titleLabel)
        
        canyons.forEach { canyon in
            let view = SubCanyonView()
            view.configure(with: canyon.name)
            view.didSelect.subscribeOnNext { [weak self] () in
                self?.didSelectSubject.onNext(canyon)
            }.disposed(by: self.bag)
            self.canyonStack.addArrangedSubview(view)
            self.canyonStack.addArrangedSubview(UIView.createLineView())
        }
    }
}
