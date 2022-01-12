//
//  RegionResultView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

class RegionResultView: UIView {
    
    enum Strings {
        static func name(with name: String) -> String {
            return "\(name)"
        }
        static func childrenCount(count: Int) -> String {
            return "\(count) subareas"
        }
        static let region = "Region"
    }
    
    public let didSelect: Observable<Void>
    private let didSelectSubject: PublishSubject<Void>
    
    private let masterStackView = UIStackView()
    private let regionNameStackView = UIStackView()
    // RHS details
    private let detailStackView = UIStackView()
    
    private let name = UILabel()
    private let regionTag = TagView()
    private let childrenCount = UILabel()
    
    init() {
        self.didSelectSubject = PublishSubject()
        self.didSelect = self.didSelectSubject.asObservable()
        
        super.init(frame: .zero)
    
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
        
        self.masterStackView.axis = .horizontal
        self.masterStackView.spacing = Grid.medium
        self.masterStackView.addArrangedSubview(self.regionNameStackView)
        self.masterStackView.addArrangedSubview(self.detailStackView)
        self.masterStackView.alignment = .center
        self.masterStackView.distribution = .equalCentering
        
        self.regionNameStackView.axis = .horizontal
        self.regionNameStackView.spacing = Grid.small
        self.regionNameStackView.addArrangedSubview(self.name)
        self.regionNameStackView.addArrangedSubview(self.regionTag)
        
        self.name.numberOfLines = 0
        self.name.setContentHuggingPriority(.required, for: .horizontal)
        self.name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.regionTag.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.detailStackView.axis = .vertical
        self.detailStackView.spacing = Grid.medium
        self.detailStackView.addArrangedSubview(self.childrenCount)
        self.detailStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.regionTag.configure(
            name: Strings.region,
            background: ColorPalette.GrayScale.black,
            text: ColorPalette.GrayScale.white
        )
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with result: SearchResult) {
        guard let region = result.regionDetails else {
            return
        }
        
        self.name.text = Strings.name(with: region.name)
        self.childrenCount.text = Strings.childrenCount(count: region.children.count)
    }
    
    @objc func didTap() {
        self.didSelectSubject.onNext(())
    }
}
