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
        static let nearMe = "Near Me"
    }
    
    private let headerImage = UIImageView()
    private let searchView = GlobalSearchView()
    private let viewMapButton = ContainedButton()
    private let nearMeButton = ContainedButton()
    private let regionList = RegionListView()
    
    private let loadingComponent = LoadingComponent()
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet.circle"), style: .plain, target: self, action: #selector(showFavorites))
        
        self.configureViews()
        self.bind()
    }
    
    private func configureViews() {
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = Grid.large
        
        self.masterStackView.addArrangedSubview(self.headerImage)
        self.masterStackView.addArrangedSubview(self.searchView)
        self.masterStackView.addArrangedSubview(self.viewMapButton)
        self.masterStackView.addArrangedSubview(self.nearMeButton)
        self.masterStackView.addArrangedSubview(self.regionList)
        
        self.headerImage.constrain.height(220)
        self.headerImage.contentMode = .scaleAspectFill
        self.headerImage.image = UIImage(named: "img_hand_line")
        self.headerImage.clipsToBounds = true
        
        self.searchView.searchTextField.delegate = self
        
        self.viewMapButton.configure(text: Strings.map)
    }
    
    private func bind() {
        self.viewMapButton.didSelect.subscribeOnNext { [weak self] () in
            guard let self = self else { return }
            self.loadingComponent.startLoading(loadingType: .screen)
            self.viewModel.canyons().subscribe(onSuccess: { [weak self] canyons in
                defer { self?.loadingComponent.stopLoading() }
                let next = MapViewController(canyons: canyons)
                self?.navigationController?.pushViewController(next, animated: true)
            }, onFailure: { error in
                defer { self.loadingComponent.stopLoading() }
                Global.logger.error("\(String(describing: error))")
            }).disposed(by: self.bag)
        }.disposed(by: self.bag)
        
        self.nearMeButton.configure(text: Strings.nearMe)
        self.nearMeButton.didSelect.flatMap { () -> Single<SearchResultList>  in
            self.loadingComponent.startLoading(loadingType: .screen)
            return self.viewModel.nearMeSearch()
        }.subscribeOnNext { [weak self] results in
            defer { self?.loadingComponent.stopLoading() }
            let next = SearchViewController(result: results)
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
        self.loadingComponent.startLoading(loadingType: .screen)
        self.viewModel.requestSearch(for: searchString).subscribe { [weak self] results in
            defer { self?.loadingComponent.stopLoading() }
            let next = SearchViewController(result: results)
            self?.navigationController?.pushViewController(next, animated: true)
        } onFailure: { error in
            defer { self.loadingComponent.stopLoading() }
            Global.logger.error("Failed search")
        }.disposed(by: self.bag)
    }
    
    @objc func showFavorites() {
        let next = FavoriteViewController()
        self.navigationController?.pushViewController(next, animated: true)
    }
}

