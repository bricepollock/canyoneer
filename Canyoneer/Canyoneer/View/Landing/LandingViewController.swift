//
//  ViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import UIKit
import RxSwift

class LandingViewController: ScrollableStackViewController {
    enum Strings {
        static let title = "Canyoneer"
        static let map = "View Map"
    }
    
    private let headerImage = UIImageView()
    private let searchView = GlobalSearchView()
    private let viewMapButton = ContainedButton()
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
        self.masterStackView.addArrangedSubview(self.viewMapButton)
        self.masterStackView.addArrangedSubview(self.regionList)
        
        self.headerImage.constrain.height(220)
        self.headerImage.contentMode = .scaleAspectFill
        self.headerImage.image = UIImage(named: "img_hand_line")
        self.headerImage.clipsToBounds = true
        
        self.searchView.searchTextField.delegate = self
        
        self.viewMapButton.configure(text: Strings.map)
        self.viewMapButton.didSelect.subscribeOnNext { [weak self] () in
            let next = MapViewController()
            self?.navigationController?.pushViewController(next, animated: true)
        }.disposed(by: self.bag)
        
        self.regionList.didSelect.subscribeOnNext { [weak self] region in
            let next = RegionViewController(region: region)
            self?.navigationController?.pushViewController(next, animated: true)
        }.disposed(by: self.bag)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Strings.title
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

