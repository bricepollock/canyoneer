//
//  RegionViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

class RegionViewController: ScrollableStackViewController {
    enum Strings {
        static func name(with name: String) -> String {
            return "Region: \(name)"
        }
    }
    private let name = UILabel()
    private let subRegionView = SubRegionListView()
    
    private let region: Region
    private let bag = DisposeBag()
    
    init(region: Region) {
        self.region = region
        super.init(insets: .init(all: .medium), atMargin: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = .medium
        self.masterStackView.addArrangedSubview(self.name)
        self.masterStackView.addArrangedSubview(self.subRegionView)
        
        self.title = Strings.name(with: region.name)
        self.subRegionView.configure(with: region.children)
        self.subRegionView.didSelect.subscribeOnNext { [weak self] region in
            let next = RegionViewController(region: region)
            self?.navigationController?.pushViewController(next, animated: true)
        }.disposed(by: self.bag)
    }
}
