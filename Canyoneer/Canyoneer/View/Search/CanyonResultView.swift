//
//  CanyonResultView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

class CanyonResultView: UIView {
    
    enum Strings {
        static func name(with name: String) -> String {
            return "\(name)"
        }
        static func rapCount(count: Int?) -> String {
            guard let count = count else {
                return "Raps: --"
            }
            return "Raps: \(count)"
        }
        static func rapLength(feet: Int?) -> String {
            guard let feet = feet else {
                return "Max: -- ft"
            }
            return "Max: \(feet) ft"
        }
    }
    
    public let didSelect: Observable<Void>
    private let didSelectSubject: PublishSubject<Void>
    
    private let masterStackView = UIStackView()
    private let canyonNameStackView = UIStackView()
    // RHS details
    private let detailStackView = UIStackView()
    
    private let name = UILabel()
    private let qualityStack = UIStackView()
    private let summary = UILabel()
    
    init() {
        self.didSelectSubject = PublishSubject()
        self.didSelect = self.didSelectSubject.asObservable()
        
        super.init(frame: .zero)
    
        self.addSubview(self.masterStackView)
        self.masterStackView.constrain.fillSuperview()
        
        self.masterStackView.axis = .horizontal
        self.masterStackView.spacing = Grid.medium
        self.masterStackView.addArrangedSubview(self.canyonNameStackView)
        self.masterStackView.addArrangedSubview(self.detailStackView)
        self.masterStackView.alignment = .center
        self.masterStackView.distribution = .equalCentering

        self.canyonNameStackView.axis = .horizontal
        self.canyonNameStackView.spacing = Grid.small
        self.canyonNameStackView.addArrangedSubview(self.name)
        self.canyonNameStackView.alignment = .leading
        self.canyonNameStackView.distribution = .equalCentering
        
        self.name.numberOfLines = 0
        self.name.setContentHuggingPriority(.required, for: .horizontal)
        self.name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        self.detailStackView.axis = .vertical
        self.detailStackView.spacing = Grid.medium
        self.detailStackView.alignment = .center
        self.detailStackView.addArrangedSubview(self.qualityStack)
        self.detailStackView.addArrangedSubview(self.summary)

        self.qualityStack.axis = .horizontal
        self.qualityStack.spacing = 1
        self.summary.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with result: SearchResult) {
        let canyon = result.canyonDetails
        self.name.text = Strings.name(with: canyon.name)
        
        // special rendering needed for array of images becuase there is no half-star emoji we could put in text
        self.qualityStack.removeAll()
        CanyonDetailView.stars(quality: canyon.quality).forEach { image in
            let imageView = UIImageView(image: image)
            imageView.constrain.width(20)
            imageView.constrain.aspect(1)
            imageView.contentMode = .scaleAspectFit
            self.qualityStack.addArrangedSubview(imageView)
        }
        self.summary.text = " " + CanyonDetailView.Strings.summaryDetails(for: canyon)
    }
    
    @objc func didTap() {
        self.didSelectSubject.onNext(())
    }
}
