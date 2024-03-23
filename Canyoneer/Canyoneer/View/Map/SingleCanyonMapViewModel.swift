//  Created by Brice Pollock for Canyoneer on 3/8/24

import Foundation
import Combine
import SwiftUI

@MainActor
class SingleCanyonMapViewModel: ObservableObject {
    private let canyon: Canyon
    private let mapOwner: MapboxMapViewOwner
    public let mapView: AnyUIKitView
    
    init(
        canyon: Canyon,
        locationService: LocationService = LocationService()
    ) {
        self.canyon = canyon
        self.mapOwner = MapboxMapViewOwner(locationService: locationService)
        self.mapView = mapOwner.view
        
        self.mapOwner.initialize()
        self.mapOwner.focusCameraOn(canyon: canyon)
        self.mapOwner.renderPolylines(for: canyon)
        self.mapOwner.renderWaypoints(canyon: canyon)
    }
}
