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
        static func title(name: String, subRegionsCount: Int, subCanyonsCount: Int) -> String {
            if subRegionsCount == 0 {
                return "\(name) (canyons: \(subCanyonsCount))"
            } else {
                return "\(name) (regions: \(subRegionsCount))"
            }
            
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
    
    func configure(with region: Region) {
        self.name.text = Strings.title(
            name: region.name,
            subRegionsCount: region.children.count,
            subCanyonsCount: region.canyons.count
        )
    }
    
    @objc func didTap() {
        self.didSelectSubject.onNext(())
    }
}
