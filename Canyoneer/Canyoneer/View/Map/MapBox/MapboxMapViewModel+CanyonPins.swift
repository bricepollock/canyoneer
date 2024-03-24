//  Created by Brice Pollock for Canyoneer on 3/24/24

import Foundation
import CoreLocation
import MapboxMaps
import UIKit

// Handles all rendering of canyon pins
extension MapboxMapViewModel {

    /// - Warning: Not necessarily efficient (See complexity of `compare` method
    /// While a simple-replace is more efficient, it results in some map-flashing where existing lines are removed and then re-adding. This approach, while more complex, results in no-flashing on removal
    public func updateCanyonPins(to new: [CanyonIndex]) {
        Global.logger.debug("Rendering canyons: \(new.count)")
        let comparisonLookup = new.compare(to: canyonPinManager.annotations)
        
        // Add new lines
        let newAnnotations = comparisonLookup.added.values.map {
            makePointAnnotation(for: $0)
        }
        canyonPinManager.annotations.append(contentsOf: newAnnotations)
        
        // Remove old lines
        canyonPinManager.annotations.removeAll {
            guard let canyonID = $0.canyonId else {
                return false
            }
            return comparisonLookup.removed[canyonID] != nil
        }
    }
    
    func makePointAnnotation(for canyon: CanyonIndex) -> PointAnnotation {
        var annotation = PointAnnotation(id: PointAnnotation.canyonPinId(for: canyon), coordinate: canyon.coordinate.asCLObject)
                
        let image = UIImage(named: "canyon_pin")!
        annotation.image = PointAnnotation.Image(image: image, name: "canyon_pin")
        annotation.textField = canyon.name
        annotation.iconAnchor = .bottom
        annotation.iconOffset = [0, -12]
        annotation.tapHandler = { [weak self] _ in
            self?.didRequestCanyon.send(canyon)
            return true
        }
        return annotation
    }
}

// Test Code
//var manager: PointAnnotationManager!
//extension MapboxMapViewModel {
//    func setupDropPinAtCameraCenter() {
//        return
//        
//        let clusterOptions = ClusterOptions()
//        manager = mapView.annotations.makePointAnnotationManager(id: "camera-points", clusterOptions: clusterOptions)
//        manager.textAllowOverlap = false
//        manager.iconAllowOverlap = true
//        manager.textOptional = true
//        mapView.mapboxMap.onCameraChanged
//            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
//            .sink { [weak self] cameraChanged in
//            guard let self else { return }
//                
//                guard mapView.mapboxMap.isStyleLoaded else {
//                    return
//                }
//            self.dropPinAtCameraCenter()
//        }.store(in: &bag)
//    }
//    
//    func dropPinAtCameraCenter() {
//        let center = mapView.mapboxMap.cameraState.center
//        let annotation = makePointAnnotation(id: UUID().uuidString, coordinate: center)
//        manager.annotations = manager.annotations + [annotation]
//    }
//    
//    func makePointAnnotation(id: String, coordinate: CLLocationCoordinate2D) -> PointAnnotation {
//        var annotation = PointAnnotation(id: id, coordinate: coordinate)
//                
//        let image = UIImage(named: "canyon_pin")!
//        annotation.image = PointAnnotation.Image(image: image, name: "canyon_pin")
//        annotation.textField = "Center Camera Pin"
//        annotation.iconAnchor = .bottom
//        annotation.iconOffset = [0, -12]
//        return annotation
//    }
//}
