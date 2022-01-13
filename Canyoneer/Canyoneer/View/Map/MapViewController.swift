//
//  MapViewController.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import MapKit
import CoreLocation
import RxSwift

class CanyonAnnotation: MKPointAnnotation {
    public let canyon: Canyon
    
    init(canyon: Canyon) {
        self.canyon = canyon
        super.init()
        self.title = canyon.name
        self.coordinate = canyon.coordinate.asCLObject
    }
}

class WaypointAnnotation: MKPointAnnotation {
    init(feature: CoordinateFeature) {
        super.init()
        self.title = feature.name
        self.coordinate = feature.coordinates[0].asCLObject
    }
}

enum TopoLineType {
    case driving
    case approach
    case descent
    case exit
    
    var color: UIColor {
        switch self {
        case .driving: return ColorPalette.Color.action
        case .approach: return ColorPalette.Color.green
        case .descent: return ColorPalette.Color.warning
        case .exit: return ColorPalette.Color.yellow
        }
    }
}

class TopoLineOverlay: MKPolyline {
    var name: String?
    var type: TopoLineType? {
        guard let name = name else { return nil }
        if name.lowercased().contains("approach") {
            return .approach
        } else if name.lowercased().contains("drive") || name.lowercased().contains("shuttle") {
            return .driving
        } else if name.lowercased().contains("descent") {
            return .descent
        } else if name.lowercased().contains("exit") {
            return .exit
        } else {
            return nil
        }
    }
}

class MapViewController: UIViewController {
    enum Strings {
        static let showTopoLines = "Show Topo Lines"
    }
    
    private let locationService = LocationService()
    internal let mapView = MKMapView()
    private let showLineOverlayStack = UIStackView()
    private let showLineOverlayTitle = UILabel()
    private let showLineOverlaySwitch = UISwitch()
    private let filterSheet = BottomSheetFilterViewController.shared
    
    private var mapOverlays = [MKPolyline]()
    private let canyons: [Canyon]
    private let viewModel = MapViewModel()
    private let bag = DisposeBag()
    
    init(canyons: [Canyon]) {
        self.canyons = canyons
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.mapView)
        self.navigationItem.backButtonTitle = ""
        
        let listButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet.rectangle"), style: .plain, target: self, action: #selector(didRequestList))
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(didRequestFilters))
        let isFullMapView = self.navigationController?.viewControllers.count == 2
        self.navigationItem.rightBarButtonItems = isFullMapView ? [listButton, filterButton] : []
        self.filterSheet.willDismiss.subscribeOnNext { () in
            self.updateWithFilters()
        }.disposed(by: self.bag)
        
        self.mapView.constrain.fillSuperview()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.updateInitialRegion()
        self.render(canyons: self.canyons)
        
        self.mapView.addSubview(self.showLineOverlayStack)
        self.showLineOverlayStack.constrain.trailing(to: self.mapView, with: -Grid.medium)
        self.showLineOverlayStack.constrain.bottom(to: self.mapView, with: -Grid.medium)
        
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
    
    private func updateInitialRegion() {
        let utahCenter = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        self.mapView.region = MKCoordinateRegion(center: utahCenter, span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20))
    }
    
    private func render(canyons: [Canyon]) {
        // clear map
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
        
        // Render annotations
        canyons.forEach { canyon in
            let annotation = CanyonAnnotation(canyon: canyon)
            self.mapView.addAnnotation(annotation)
        }
        
        // render lines
        let overlays = canyons.flatMap { canyon in
            return canyon.geoLines.map { feature -> MKPolyline in
                print("Topo Line Named: \(String(describing: feature.name))")
                let overlay = TopoLineOverlay(coordinates: feature.coordinates.map { $0.asCLObject }, count: feature.coordinates.count)
                overlay.name = feature.name
                return overlay
            }
        }
        self.mapOverlays = overlays
        overlays.forEach {
            self.mapView.addOverlay($0)
        }
        
        // render waypoints if only showing one canyon
        if canyons.count == 1 {
            let waypoints = canyons.flatMap { canyon in
                canyon.geoWaypoints.map { feature in
                    return WaypointAnnotation(feature: feature)
                }
            }
            waypoints.forEach { annotation in
                self.mapView.addAnnotation(annotation)
            }
        }
        
        // center location
        if canyons.count == 1 {
            let center = canyons[0].coordinate.asCLObject
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            self.mapView.setRegion(region, animated: true)
        } else if locationService.isLocationEnabled() {
            self.locationService.getCurrentLocation { location in
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    private func updateWithFilters() {
        // perfom filter
        let original = canyons.map { SearchResult(name: $0.name, type: .canyon, canyonDetails: $0, regionDetails: nil)}
        let results = self.filterSheet.viewModel.filter(results: original)
        let canyons = results.compactMap {
            return $0.canyonDetails
        }
        self.render(canyons: canyons)
    }
    
    // MARK: Actions
    
    @objc func didRequestFilters() {
        self.present(self.filterSheet, animated: false)
    }
    
    @objc func didRequestList() {
        let canyons = self.mapView.visibleAnnotations().compactMap {
            return $0 as? CanyonAnnotation
        }.map {
            return SearchResult(name: $0.canyon.name, type: .canyon, canyonDetails: $0.canyon, regionDetails: nil)
        }
        let next = SearchViewController(type: .map(list: canyons))
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @objc func lineOverlaySwitchChanged() {
        if showLineOverlaySwitch.isOn {
            guard self.mapView.overlays.isEmpty else {
                return // we already added the overlays
            }
            self.mapOverlays.forEach {
                self.mapView.addOverlay($0)
            }
        } else {
            self.mapView.removeOverlays(self.mapView.overlays)
        }
    }
}
