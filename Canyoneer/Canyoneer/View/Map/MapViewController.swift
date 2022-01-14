//
//  MapViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import CoreLocation
import RxSwift

enum CanyonMapType {
    case apple
    case mapbox
}

class MapViewController: UIViewController {
    enum Strings {
        static let showTopoLines = "Show Route Lines"
        static let legend = "Legend"
    }
    
    private let locationService = LocationService()
    internal let mapView: CanyonMap
    private let showLegendButton = RxUIButton()
    private let showLineOverlayStack = UIStackView()
    private let showLineOverlayTitle = UILabel()
    private let showLineOverlaySwitch = UISwitch()
    private let filterSheet = BottomSheetFilterViewController.shared

    private let canyons: [Canyon]
    private let viewModel = MapViewModel()
    private let bag = DisposeBag()
    
    init(type: CanyonMapType, canyons: [Canyon]) {
        self.canyons = canyons
        switch type {
        case .apple: self.mapView = AppleMapView()
        case .mapbox: self.mapView = MapboxMapView()
        }
        super.init(nibName: nil, bundle: nil)
        self.mapView.didRequestCanyon.subscribeOnNext { [weak self] canyonId in
            let next = CanyonViewController(canyonId: canyonId)
            self?.navigationController?.pushViewController(next, animated: true)
        }.disposed(by: self.bag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.mapView.view)
        self.navigationItem.backButtonTitle = ""
        
        let listButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet.rectangle"), style: .plain, target: self, action: #selector(didRequestList))
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(didRequestFilters))
        let isFullMapView = self.navigationController?.viewControllers.count == 2
        self.navigationItem.rightBarButtonItems = isFullMapView ? [listButton, filterButton] : []
        self.filterSheet.willDismiss.subscribeOnNext { () in
            self.updateWithFilters()
        }.disposed(by: self.bag)
        
        self.mapView.view.constrain.fillSuperview()
        self.mapView.initialize()
        self.mapView.updateInitialCamera()
        self.mapView.render(canyons: canyons)
        self.mapView.updateCamera(canyons: canyons)
        self.renderControls()
    }
    
    private func renderControls() {
        let mapControlsStackView = UIStackView()
        mapControlsStackView.axis = .vertical
        mapControlsStackView.spacing = .small
        mapControlsStackView.alignment = .trailing
        
        self.mapView.view.addSubview(mapControlsStackView)
        mapControlsStackView.constrain.trailing(to: self.mapView.view, with: -Grid.medium)
        mapControlsStackView.constrain.bottom(to: self.mapView.view, with: -Grid.medium)
        mapControlsStackView.addArrangedSubview(self.showLegendButton)
        mapControlsStackView.addArrangedSubview(self.showLineOverlayStack)
        
        self.showLegendButton.configure(text: Strings.legend)
        self.showLegendButton.didSelect.subscribeOnNext { () in
            let bottomSheet = MapLegendBottomSheetViewController()
            self.present(bottomSheet, animated: false)
        }.disposed(by: self.bag)
        
        self.showLineOverlayStack.axis = .horizontal
        self.showLineOverlayStack.spacing = .medium
        self.showLineOverlayStack.addArrangedSubview(self.showLineOverlayTitle)
        self.showLineOverlayStack.addArrangedSubview(self.showLineOverlaySwitch)
        
        self.showLineOverlayTitle.text = Strings.showTopoLines
        self.showLineOverlayTitle.font = FontBook.Subhead.emphasis
        self.showLineOverlayTitle.textColor = ColorPalette.GrayScale.black
        self.showLineOverlaySwitch.isOn = true
        self.showLineOverlaySwitch.addTarget(self, action: #selector(lineOverlaySwitchChanged), for: .valueChanged)
    }
    
    private func updateWithFilters() {
        self.filterSheet.update()
        // perfom filter
        let original = canyons.map { SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)}
        let results = self.filterSheet.viewModel.filter(results: original)
        let canyons = results.compactMap {
            return $0.canyonDetails
        }
        self.mapView.render(canyons: canyons)
    }
    
    // MARK: Actions
    
    @objc func didRequestFilters() {
        self.present(self.filterSheet, animated: false)
    }
    
    @objc func didRequestList() {
        let canyons = self.mapView.visibleCanyons.map {
            return SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)
        }
        let next = SearchViewController(type: .map(list: canyons))
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @objc func lineOverlaySwitchChanged() {
        if showLineOverlaySwitch.isOn {
            self.mapView.renderPolylinesFromCache()
        } else {
            self.mapView.removePolylines()
        }
    }
}
