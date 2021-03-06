//
//  AppleMapView.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import MapKit
import RxSwift

class AppleMapView: NSObject, CanyonMap {
    public var locationService = LocationService()
    
    private let mapView = MKMapView()
    public var view: UIView {
        return mapView
    }
    
    public let didRequestCanyon: Observable<String>
    private let didRequestCanyonSubject: PublishSubject<String>
    
    private var mapOverlays = [MKOverlay]()
    private var headingView: UIView?
    private let bag = DisposeBag()
    
    override init() {
        self.didRequestCanyonSubject = PublishSubject()
        self.didRequestCanyon = self.didRequestCanyonSubject.asObservable()
        super.init()
    }
    
    public var visibleCanyons: [Canyon] {
        return self.mapView.visibleAnnotations().compactMap {
            return ($0 as? CanyonAnnotation)?.canyon
        }
    }
    
    public func initialize() {
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        
        self.locationService.didUpdateHeading.subscribeOnNext { newHeading in
            if newHeading.headingAccuracy < 0 { return }
            let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
            if let headingView = self.headingView {
                let rotation = CGFloat(heading/180 * Double.pi)
                headingView.transform = CGAffineTransform(rotationAngle: rotation)
            }
        }.disposed(by: self.bag)
    }
    
    public func renderAnnotations(canyons: [Canyon]) {
        canyons.forEach { canyon in
            let annotation = CanyonAnnotation(canyon: canyon)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    public func removeAnnotations() {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    public func renderPolylines(canyons: [Canyon]) {
        let overlays = canyons.flatMap { canyon in
            return canyon.geoLines.map { feature -> MKPolyline in
                let overlay = TopoLineOverlay(coordinates: feature.coordinates.map { $0.asCLObject }, count: feature.coordinates.count)
                overlay.name = feature.name
                
                if let hex = feature.hexColor {
                    overlay.color = UIColor.hex(hex)
                }
                return overlay
            }
        }
        self.mapOverlays = overlays
        overlays.forEach {
            self.mapView.addOverlay($0)
        }
    }
    
    public func renderPolylinesFromCache() {
        guard self.mapView.overlays.isEmpty else {
            return // we already added the overlays
        }
        self.mapOverlays.forEach {
            self.mapView.addOverlay($0)
        }
    }
    
    public func removePolylines() {
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    public func renderWaypoints(canyon: Canyon) {
        let waypoints = canyon.geoWaypoints.map { feature in
            return WaypointAnnotation(feature: feature)
        }
        waypoints.forEach { annotation in
            self.mapView.addAnnotation(annotation)
        }
    }
    
    public func updateInitialCamera() {
        let utahCenter = CLLocationCoordinate2D(latitude: 39.3210, longitude: -111.0937)
        self.mapView.region = MKCoordinateRegion(center: utahCenter, span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20))
    }
    
    public func focusCameraOn(canyon: Canyon) {
        let center = canyon.coordinate.asCLObject
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.mapView.setRegion(region, animated: true)
    }
    
    public func focusCameraOn(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        self.mapView.setRegion(region, animated: true)
    }
}

extension AppleMapView: MKMapViewDelegate {
 
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let mkAnnotation = view.annotation, let annotation = mkAnnotation as? CanyonAnnotation else {
            return
        }
        self.didRequestCanyonSubject.onNext(annotation.canyon.id)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation.title != "My Location" else {
            let image = UIImage(systemName: "location.north.fill")!
            let headingView = UIImageView(image: image)
            self.headingView = headingView
            headingView.constrain.height(20)
            headingView.constrain.aspect(1)
            
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
            annotationView.insertSubview(headingView, at: 0)
            return annotationView
            
        }
        return NonClusteringMKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? TopoLineOverlay {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            // use our color first and then use ropewiki if we cannot find one
            renderer.strokeColor = routePolyline.type == .unknown ? routePolyline.color ?? routePolyline.type.color : routePolyline.type.color
            renderer.lineWidth = 3
            return renderer
        }

        return MKOverlayRenderer()
    }
}
