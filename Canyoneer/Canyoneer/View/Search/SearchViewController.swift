//
//  SearchViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

class SearchViewController: ScrollableStackViewController {
    
    private let filterSheet = BottomSheetFilterViewController.shared
    private lazy var downloadButton = {
        return UIBarButtonItem(image: UIImage(systemName: "arrow.down.circle"), style: .plain, target: self, action: #selector(self.didRequestDownloads))
    }()
    
    private let progressView = DownloadBar()
    private let viewModel: SearchViewModel
    private var filteredResults: [Canyon]?
    internal let bag = DisposeBag()
    
    init(type: SearchType) {
        self.viewModel = SearchViewModel(type: type)
        super.init(insets: .init(all: .medium), atMargin: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.bind()

        self.navigationItem.backButtonTitle = ""
        
        // setup loading
        self.view.addSubview(self.viewModel.loadingComponent.inlineLoader)
        self.viewModel.loadingComponent.inlineLoader.constrain.centerX(on: self.view)
        self.viewModel.loadingComponent.inlineLoader.constrain.centerY(on: self.view)
        
        // setup bar button items
        
        let mapButton = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(didRequestMap))
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(didRequestFilters))
        let wasLaunchedFromMap = (self.navigationController?.viewControllers.count ?? 0) > 2
        
        let buttons: [UIBarButtonItem]
        if wasLaunchedFromMap {
            buttons = []
        } else {
            if self.viewModel.type == .favorites {
                buttons = [mapButton, filterButton, self.downloadButton]
            } else {
                buttons = [mapButton, filterButton]
            }
        }
        self.navigationItem.rightBarButtonItems = buttons
        
        self.viewModel.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Technically this should be in the view model but it saves time and complexity with the amount of signals putting it here.
        // We need to refresh the data on appear because you could have un-favorited an item and otherwise that item would still show in your favorite list.
        if self.viewModel.type == .favorites {
            self.viewModel.refresh()
        }
    }
    
    func configureViews() {
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = Grid.medium
        self.view.addSubview(self.progressView)
        
        let sizeOfNavBar: CGFloat = 60 + 5 // spacing
        self.progressView.constrain.top(to: self.view, with: sizeOfNavBar)
        self.progressView.constrain.leading(to: self.view, with: Grid.large)
        self.progressView.constrain.trailing(to: self.view, with: -Grid.large)
        self.progressView.hide()
    }
    
    func bind() {        
        self.viewModel.title.subscribeOnNext { [weak self] title in
            self?.title = title
        }.disposed(by: self.bag)
        
        self.viewModel.results.subscribeOnNext { [weak self] result in
            self?.renderResults(results: result)
        }.disposed(by: self.bag)
        
        self.filterSheet.willDismiss.subscribeOnNext { [weak self] () in
            self?.updateWithFilters()
        }.disposed(by: self.bag)
        
        self.viewModel.hasDownloadedAll.subscribeOnNext { [weak self] haveAll in
            self?.downloadButton.image = haveAll ? UIImage(systemName: "arrow.down.circle.fill")! : UIImage(systemName: "arrow.down.circle")!
        }.disposed(by: self.bag)
        
        self.viewModel.progress.subscribeOnNext { [weak self] percentage in
            guard let self = self else { return }
            guard percentage < 1 else {
                self.progressView.update(progress: percentage)
                UIView.animate(withDuration: DesignSystem.animation) {
                    self.progressView.hide()
                }
                return
            }
            self.progressView.update(progress: percentage)
            UIView.animate(withDuration: DesignSystem.animation) {
               self.progressView.show()
            }
        }.disposed(by: self.bag)
    }
    
    internal func renderResults(results: [SearchResult]) {
        self.masterStackView.removeAll()
        self.masterStackView.addArrangedSubview(UIView.createLineView())
        results.forEach { result in
            let view: UIView
            switch result.type {
            case .canyon:
                let specificView = CanyonResultView()
                specificView.configure(with: result)
                specificView.didSelect.subscribeOnNext { [weak self] () in
                    guard let canyon = result.canyonDetails else {
                        return
                    }
                    let next = CanyonViewController(canyonId: canyon.id)
                    self?.navigationController?.pushViewController(next, animated: true)
                }.disposed(by: self.bag)
                view = specificView
            case .region:
                let specificView = RegionResultView()
                specificView.configure(with: result)
                specificView.didSelect.subscribeOnNext { [weak self] () in
                    guard let region = result.regionDetails else {
                        return
                    }
                    let next = RegionViewController(region: region)
                    self?.navigationController?.pushViewController(next, animated: true)
                }.disposed(by: self.bag)
                view = specificView
            }
            
            self.masterStackView.addArrangedSubview(view)
            self.masterStackView.addArrangedSubview(UIView.createLineView())
        }
    }
    
    private func updateWithFilters() {
        self.filterSheet.update()
        // NEED to filter off the initial results otherwise we accumulate our filters until there is none
        let filtered = self.filterSheet.viewModel.filter(results: self.viewModel.initialResults)
        self.viewModel.updateFromFilter(with: filtered)
    }
    
    @objc func didRequestMap() {
        let canyons = self.viewModel.currentResults.compactMap { $0.canyonDetails }
        let next = MapViewController(type: .apple, canyons: canyons)
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @objc func didRequestFilters() {
        self.present(self.filterSheet, animated: false)
    }
    
    @objc func didRequestDownloads() {
        self.viewModel.downloadCanyonMaps()
    }
}
