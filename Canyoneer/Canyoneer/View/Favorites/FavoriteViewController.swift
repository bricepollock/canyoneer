//
//  FavoriteViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/18/22.
//

import Foundation
import UIKit
import Combine

@MainActor
class FavoriteViewController: ResultsViewController {
    enum Strings {
        static let addFavorites = "Add favorites to this list"
    }
    private lazy var downloadButton = {
        return UIBarButtonItem(image: UIImage(systemName: "arrow.down.circle"), style: .plain, target: self, action: #selector(self.didRequestDownloads))
    }()
    private let progressView = DownloadBar()
    private let emptyStateView = UILabel()
    private let viewModel = FavoritesViewModel()
    
    private var bag = Set<AnyCancellable>()

    init() {
        super.init(type: .favorites, searchResults: [], viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backButtonTitle = ""
        var items = self.navigationItem.rightBarButtonItems ?? []
        items.append(self.downloadButton)
        self.navigationItem.rightBarButtonItems = items
        
        self.bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // We need to refresh the data on appear because you could have un-favorited an item and otherwise that item would still show in your favorite list.
        Task(priority: .high) { @MainActor [weak self] in
            await self?.viewModel.refresh()
        }
    }
    
    override func configureViews() {
        super.configureViews()
        
        let sizeOfNavBar: CGFloat = 60 + 5 // spacing
        self.view.addSubview(self.progressView)
        self.progressView.constrain.top(to: self.view, with: sizeOfNavBar)
        self.progressView.constrain.leading(to: self.view, with: Grid.large)
        self.progressView.constrain.trailing(to: self.view, with: -Grid.large)
        self.progressView.hide()
        
        self.view.addSubview(self.emptyStateView)
        self.emptyStateView.constrain.centerX(on: self.view)
        self.emptyStateView.constrain.centerY(on: self.view)
        self.emptyStateView.text = Strings.addFavorites
        self.emptyStateView.textAlignment = .center
        self.emptyStateView.font = FontBook.Body.regular
        self.emptyStateView.textColor = ColorPalette.GrayScale.gray
        self.emptyStateView.isHidden = true
    }
        
    override func bind() {
        super.bind()
        
        self.viewModel.$currentResults.sink { results in
            self.emptyStateView.isHidden = !results.isEmpty
        }.store(in: &bag)
        
        self.viewModel.$hasDownloadedAll
            .compactMap { $0 }
            .sink { [weak self] haveAll in
            self?.downloadButton.image = haveAll ? UIImage(systemName: "arrow.down.circle.fill")! : UIImage(systemName: "arrow.down.circle")!
        }.store(in: &bag)
        
        self.viewModel.$isDownloading
            .receive(on: DispatchQueue.main) // For some reason the @MainActor is not being respected
            .sink { [weak self] isDownloading in
            guard let self = self else { return }
                
            UIView.animate(withDuration: DesignSystem.animation) {
                if isDownloading {
                    self.progressView.show()
                } else {
                    self.progressView.hide()
                }
            }
        }.store(in: &bag)
        
        self.viewModel.$progress
            .compactMap { $0 }
            .receive(on: DispatchQueue.main) // For some reason the @MainActor is not being respected
            .sink { [weak self] percentage in
                guard let self = self else { return }
                self.progressView.update(progress: percentage)
        }.store(in: &bag)
    }
    
    @objc func didRequestDownloads() {
        Task(priority: .userInitiated) { @MainActor [weak self] in
            await self?.viewModel.downloadCanyonMaps()
        }
    }
}
