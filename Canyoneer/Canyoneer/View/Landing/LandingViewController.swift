//
//  ViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import UIKit
import RxSwift

class LandingViewController: ScrollableStackViewController {
    private let headerImage = UIImageView()
    private let searchView = GlobalSearchView()
    private let regionList = RegionListView()
    
    private let viewModel = LandingViewModel()
    private let bag = DisposeBag()
    
    init() {
        super.init(insets: .init(all: .medium), atMargin: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = Grid.large
        
        self.masterStackView.addArrangedSubview(self.headerImage)
        self.masterStackView.addArrangedSubview(self.searchView)
        self.masterStackView.addArrangedSubview(self.regionList)
        
        self.searchView.searchTextField.delegate = self
        
        self.regionList.didSelect.subscribeOnNext { [weak self] region in
            let next = RegionViewController(region: region)
            self?.navigationController?.pushViewController(next, animated: true)
        }.disposed(by: self.bag)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backButtonTitle = ""
        
        let regions = self.viewModel.regions()
        self.regionList.configure(with: RegionListViewData(regions: regions))
    }
    
    // MARK: Actions
    func performSearch(for searchString: String) {
        let result = self.viewModel.requestSearch(for: searchString)
        let next = SearchViewController(result: result)
        self.navigationController?.pushViewController(next, animated: true)
    }
}

