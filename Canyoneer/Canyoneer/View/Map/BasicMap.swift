//  Created by Brice Pollock for Canyoneer on 3/8/24

import Foundation
import SwiftUI
import CoreLocation
import Combine

protocol BasicMap {
    var locationService: LocationService { get }
    
    /// Setup things like delegates, current location, etc.
    func initialize()

    // MARK: Camera Methods
    
    /// Set the camera to the canyons
    func focusCameraOn(canyon: Canyon, animated: Bool)
    
    /// Set the camera to current location
    func focusCameraOn(location: CLLocationCoordinate2D, animated: Bool)
}
