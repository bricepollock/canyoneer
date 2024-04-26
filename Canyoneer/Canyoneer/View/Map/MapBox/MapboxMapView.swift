//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import UIKit
import SwiftUI

extension CLLocationCoordinate2D {
    static var zero: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}

extension CoordinateBounds {
    static var zero: CoordinateBounds {
        CoordinateBounds(southwest: CLLocationCoordinate2D.zero, northeast: CLLocationCoordinate2D.zero)
    }
}

protocol MapboxMapController: AnyObject {
    func didLoad(mapView: MapView)
}

class MapboxMapViewController: UIViewController {
    internal var mapView: MapView!
    weak var controller: MapboxMapController?
    
    init(controller: MapboxMapController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myMapInitOptions = MapInitOptions(
            styleURI: StyleURI.outdoors
        )
        mapView = MapboxMaps.MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
        controller?.didLoad(mapView: mapView)
    }
}
