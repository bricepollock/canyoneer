//
//  RegionListView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

struct RegionListViewData {
    let regions: [Region]
}

class RegionListView: UIView {
    
    enum Strings {
        static let header = " Regions"
    }
    
    public let didSelect: Observable<Region>
    private let didSelectSubject: PublishSubject<Region>
    
    private let header = UILabel()
    private let masterStackView = UIStackView()
    private let bag = DisposeBag()
    
    init() {
        self.didSelectSubject = PublishSubject()
        self.didSelect = self.didSelectSubject.asObservable()
        
        super.init(frame: .zero)
        
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = .small
        
        self.header.text = Strings.header
        self.header.backgroundColor = ColorPalette.Color.canyonRed
        self.header.font = FontBook.Body.emphasis
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: RegionListViewData) {
        self.masterStackView.removeAll()
        self.masterStackView.addArrangedSubview(self.header)
        data.regions.forEach { region in
            let view = RegionListRow()
            view.configure(with: region.name)
            view.didSelect.subscribeOnNext { [weak self] () in
                self?.didSelectSubject.onNext(region)
            }.disposed(by: self.bag)
            
            self.masterStackView.addArrangedSubview(view)
            self.masterStackView.addArrangedSubview(UIView.createLineView())
        }
    }
}

