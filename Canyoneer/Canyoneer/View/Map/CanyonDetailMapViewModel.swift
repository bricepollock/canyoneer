//  Created by Brice Pollock for Canyoneer on 12/10/23

import Foundation
import Combine
import SwiftUI

/// The view model for the detailed view of a single canyon
@MainActor class CanyonDetailMapViewModel: ObservableObject {
    public let canyon: Canyon
    public let mapView: CanyonMapViewType
    public let canyonMapViewOwner: any CanyonMap
    
    private let locationService: LocationService
    private var bag = Set<AnyCancellable>()
    
    init(
        type: CanyonMapType,
        canyon: Canyon,
        locationService: LocationService = LocationService()
    ) {
        self.locationService = locationService
        
        self.canyon = canyon
        switch type {
        case .apple:
            canyonMapViewOwner = AppleMapViewOwner()
        case .mapbox:
            canyonMapViewOwner = MapboxMapViewOwner()
        }
        self.mapView = canyonMapViewOwner.view
        self.canyonMapViewOwner.initialize()
        self.canyonMapViewOwner.updateInitialCamera()
        self.canyonMapViewOwner.render(canyon: canyon)

        Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.canyonMapViewOwner.updateCamera(to: canyon)
            } catch {
                Global.logger.error(error)
            }
        }
    }
}

