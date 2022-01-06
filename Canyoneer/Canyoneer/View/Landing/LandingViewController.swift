//
//  ViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import UIKit

class LandingViewController: ScrollableStackViewController {
    private let headerImage = UIImageView()
    private let searchView = GlobalSearchView()
    private let regionList = RegionListView()
    
    private let viewModel = LandingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = Grid.large
        
        self.masterStackView.addArrangedSubview(self.headerImage)
        self.masterStackView.addArrangedSubview(self.searchView)
        self.masterStackView.addArrangedSubview(self.regionList)
        
        self.searchView.searchTextField.delegate = self
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

