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
        self.coordinate = canyon.coordinate
    }
}

class MapViewController: UIViewController {
    enum Strings {
        static let save = "Save"
    }
    
    private let locationService = LocationService()
    internal let mapView = MKMapView()
    private let rappelFilter = RappelFilterView()
    
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
        
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(didRequestFilters))
        self.navigationItem.rightBarButtonItems = [filterButton]
        
        self.mapView.constrain.fillSuperview()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        
        let utahCenter = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        self.mapView.region = MKCoordinateRegion(center: utahCenter, span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20))
        
        if locationService.isLocationEnabled() {
            self.locationService.getCurrentLocation { location in
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
                self.mapView.setRegion(region, animated: true)
            }
        }

        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        self.canyons.forEach { canyon in
            let annotation = CanyonAnnotation(canyon: canyon)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    private func updateWithFilters() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        let canyons = self.canyons.filter { canyon in
            // filter out canyons without this rap information
            guard let maxRap = canyon.maxRapLength else {
                return false
            }
            return maxRap >= self.rappelFilter.minRappels && maxRap <= self.rappelFilter.maxRappels
        }
        canyons.forEach { canyon in
            let annotation = CanyonAnnotation(canyon: canyon)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    @objc func didRequestFilters() {
        let bottomSheet = BottomSheetViewController()
        bottomSheet.modalPresentationStyle = .overCurrentContext
        
        let saveButton = ContainedButton()
        saveButton.configure(text: Strings.save)
        saveButton.didSelect.subscribeOnNext { () in
            bottomSheet.animateDismissView()
        }.disposed(by: self.bag)
        
        bottomSheet.contentStackView.spacing = .medium
        bottomSheet.contentStackView.addArrangedSubview(rappelFilter)
        bottomSheet.contentStackView.addArrangedSubview(saveButton)
        bottomSheet.contentStackView.addArrangedSubview(UIView())
        bottomSheet.willDismiss.subscribeOnNext { () in
            self.updateWithFilters()
        }.disposed(by: self.bag)
        self.present(bottomSheet, animated: false)
    }
}
