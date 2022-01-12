//
//  MapViewControler+MapViewDelegate.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import UIKit
import MapKit

extension MapViewController: MKMapViewDelegate {
 
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let mkAnnotation = view.annotation, let annotation = mkAnnotation as? CanyonAnnotation else {
            return
        }
        
        let next = CanyonViewController(canyonId: annotation.canyon.id)
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation.title != "My Location" else {
            return nil
        }
        return NonClusteringMKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
    }
}
