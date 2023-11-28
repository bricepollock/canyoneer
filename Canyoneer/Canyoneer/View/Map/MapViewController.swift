//
//  MapViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import CoreLocation
import Combine

enum CanyonMapType {
    case apple
    case mapbox
}

@MainActor
class MapViewController: UIViewController {
    enum Strings {
        static let showTopoLines = "Show Route Lines"
        static let legend = "Legend"
    }
    
    private let locationService = LocationService()
    internal let mapView: CanyonMap
    private let showLegendButton = CombineUIButton()
    private let showLineOverlayStack = UIStackView()
    private let showLineOverlayTitle = UILabel()
    private let showLineOverlaySwitch = UISwitch()
    private let filterSheet = BottomSheetFilterViewController.shared

    private var hasLoaded: Bool = false
    private var initialCanyons: [Canyon]
    private let viewModel = MapViewModel()
    private var bag = Set<AnyCancellable>()
    
    init(type: CanyonMapType, canyons: [Canyon]) {
        self.initialCanyons = canyons
        switch type {
        case .apple: self.mapView = AppleMapView()
        case .mapbox: self.mapView = MapboxMapView()
        }
        super.init(nibName: nil, bundle: nil)
        self.mapView.didRequestCanyon.sink { [weak self] canyonId in
            let next = CanyonViewController(canyonId: canyonId)
            self?.navigationController?.pushViewController(next, animated: true)
        }.store(in: &bag)
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
        let isFullMapView = self.navigationController?.viewControllers.count == 1
        self.navigationItem.rightBarButtonItems = isFullMapView ? [listButton, filterButton] : []
        self.filterSheet.willDismiss.sink { [weak self] _ in
            self?.updateWithFilters()
        }.store(in: &bag)
        
        self.mapView.view.constrain.top(to: self.view)
        self.mapView.view.constrain.bottom(to: self.view, atMargin: true)
        self.mapView.view.constrain.leading(to: self.view)
        self.mapView.view.constrain.trailing(to: self.view)
        self.mapView.initialize()
        self.mapView.updateInitialCamera()
    }
    
    // wait until view did appear so we don't hang the main thread trying to render everything
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // only do the load once, important when we think about switching tabs
        guard self.hasLoaded == false else { return }
        self.hasLoaded = true
        
        Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                if initialCanyons.isEmpty {
                    let canyons = await self.viewModel.canyons()
                    self.initialCanyons = canyons
                    self.mapView.render(canyons: canyons)
                    try await self.mapView.updateCamera(canyons: canyons)
                } else {
                    self.mapView.render(canyons: initialCanyons)
                    try await self.mapView.updateCamera(canyons: initialCanyons)
                }
            } catch {
                Global.logger.error(error)
            }
            self.renderControls()
        }
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
        self.showLegendButton.didSelect.sink { () in
            let bottomSheet = MapLegendBottomSheetViewController()
            self.present(bottomSheet, animated: false)
        }.store(in: &bag)
        
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
        let original = initialCanyons.map { SearchResult(name: $0.name, canyonDetails: $0)}
        let results = self.filterSheet.viewModel.filter(results: original)
        let canyons = results.compactMap {
            return $0.canyonDetails
        }
        self.mapView.render(canyons: canyons)
    }
    
    // MARK: Actions
    
    @objc func didRequestFilters() {
        self.tabBarController?.present(self.filterSheet, animated: false)
    }
    
    @objc func didRequestList() {
        let next = MapListViewController(canyons: self.mapView.visibleCanyons)
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
