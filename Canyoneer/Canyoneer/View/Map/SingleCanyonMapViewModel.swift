//  Created by Brice Pollock for Canyoneer on 3/8/24

import Foundation
import Combine
import SwiftUI

@MainActor
class SingleCanyonMapViewModel: ObservableObject {
    public let mapViewModel: MapboxMapViewModel
    private let canyon: Canyon
        
    init(
        canyon: Canyon,
        locationService: LocationService = LocationService()
    ) {
        self.canyon = canyon
        self.mapViewModel = MapboxMapViewModel(locationService: locationService)
    }
    
    func onAppear() {
        self.mapViewModel.initialize()
        self.mapViewModel.focusCameraOn(canyon: canyon)
        self.mapViewModel.updatePolylines(to: [canyon])
        self.mapViewModel.renderWaypoints(canyon: canyon)
    }
}
