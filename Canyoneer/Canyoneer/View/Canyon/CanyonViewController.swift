//
//  CanyonViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import RxSwift

class CanyonViewController: ScrollableStackViewController {
    enum Strings {
        static let canyon = "Canyon Details"
        static func message(for canyon: Canyon) -> String {
            var message = "I found '\(canyon.name) \(CanyonDetailView.Strings.summaryDetails(for: canyon))' on the 'Canyoneer' app."
            if let ropeWikiString = canyon.ropeWikiURL?.absoluteString {
                message += " Check out the canyon on Ropewiki: \(ropeWikiString)"
            }
            return message
        }
        
        static func subject(name: String) -> String {
            return "Check out this cool canyon: \(name)"
        }
        
        static func body(for canyon: Canyon) -> String {
            var body = "I found '\(canyon.name) \(CanyonDetailView.Strings.summaryDetails(for: canyon))' on the 'Canyoneer' app."
            if let ropeWikiString = canyon.ropeWikiURL?.absoluteString {
                body += " Check out the canyon on Ropewiki: \(ropeWikiString)"
            }
            return body
        }
    }

    private let name = UILabel()
    private let detailView = CanyonDetailView()
    private let viewModel: CanyonViewModel
    private let bag = DisposeBag()
    
    // MARK: lifecycle
    init(canyonId: String) {
        self.viewModel = CanyonViewModel(canyonId: canyonId)
        super.init(insets: .init(all: .medium), atMargin: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
        self.bind()
        
        self.title = Strings.canyon
        self.navigationItem.backButtonTitle = ""
        
        // setup bar button items
        let gpxButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(didRequestShareGPX))
        
        let mapButton = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(didRequestMap))
        
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(self.didRequestShare))
                
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(self.didRequestFavoriteToggle))
        self.navigationItem.rightBarButtonItems = [favoriteButton, shareButton, mapButton, gpxButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.refresh()
    }
    
    // MARK: internal
    private func configureViews() {
        self.masterStackView.axis = .vertical
        self.masterStackView.spacing = Grid.medium
        self.masterStackView.addArrangedSubview(self.name)
        self.masterStackView.addArrangedSubview(self.detailView)
    }
    
    private func bind() {
        self.viewModel.canyonObservable.subscribeOnNext { [weak self] canyon in
            self?.detailView.configure(with: canyon)
        }.disposed(by: self.bag)
        
        self.viewModel.isFavorite.subscribeOnNext { [weak self] isFavorite in
            if isFavorite {
                self?.navigationItem.rightBarButtonItems?[0].image = UIImage(systemName: "star.fill")
            } else {
                self?.navigationItem.rightBarButtonItems?[0].image = UIImage(systemName: "star")
            }
        }.disposed(by: self.bag)
        
        self.viewModel.forecast.subscribeOnNext { forecast in
            self.detailView.configure(weather: forecast)
        }.disposed(by: self.bag)
        
        self.viewModel.shareGPXFile.subscribeOnNext { url in
            let next = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.present(next, animated: true)
        }.disposed(by: self.bag)
    }
    
    // MARK: actions
    @objc func didRequestShare() {        
        let next = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        self.present(next, animated: true)
    }
    
    @objc func didRequestShareGPX() {
        self.viewModel.requestDownloadGPX()
    }
    
    @objc func didRequestFavoriteToggle() {
        self.viewModel.toggleFavorite()
    }
    
    @objc func didRequestMap() {
        guard let thisCanyon = self.viewModel.canyon else { return }
        let next = MapViewController(type: .mapbox, canyons: [thisCanyon])
        self.navigationController?.pushViewController(next, animated: true)
    }
}

extension CanyonViewController: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        guard let canyon = self.viewModel.canyon else { return ""}
        return Strings.message(for: canyon)
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let canyon = self.viewModel.canyon else { return nil }
        if activityType == .mail {
            return Strings.body(for: canyon)
        } else {
            return Strings.message(for: canyon)
        }
        
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        guard let canyon = self.viewModel.canyon else { return "" }
        return Strings.subject(name: canyon.name)
    }
}
