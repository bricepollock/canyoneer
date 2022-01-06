//
//  SubRegionView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

class SubRegionView: UIView {
    enum Strings {
        static func name(with name: String) -> String {
            return "\t* \(name)"
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

class SubRegionListView: UIView {
    enum Strings {
        static func title(with regions: [Region]) -> String {
            let base = "Sub Regions:"
            guard !regions.isEmpty else {
                return "\(base) None"
            }
            return base
        }
    }
    public let didSelect: Observable<Region>
    private let didSelectSubject: PublishSubject<Region>
    
    private let bag = DisposeBag()
    
    private let titleLabel = UILabel()
    private let regionStack = UIStackView()
    
    init() {
        self.didSelectSubject = PublishSubject()
        self.didSelect = self.didSelectSubject.asObservable()

        super.init(frame: .zero)
        self.addSubview(self.regionStack)
        self.regionStack.constrain.fillSuperview()
        self.regionStack.spacing = .medium
        self.regionStack.axis = .vertical
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with regions: [Region]) {
        self.regionStack.removeAll()
        
        self.titleLabel.text = Strings.title(with: regions)
        self.regionStack.addArrangedSubview(self.titleLabel)
                
        regions.forEach { region in
            let view = SubRegionView()
            view.configure(with: region.name)
            view.didSelect.subscribeOnNext { [weak self] () in
                self?.didSelectSubject.onNext(region)
            }.disposed(by: self.bag)
            self.regionStack.addArrangedSubview(view)
        }
    }
}
