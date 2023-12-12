//  Created by Brice Pollock for Canyoneer on 12/10/23

import Foundation

enum Vehicle: String, Codable {
    case fourWheelDrive = "4WD"
    case fourWheelDrive_highClearance = "4WD - High Clearance"
    case fourWheelDrive_veryHighClearance = "4WD - Very High Clearance"
    case highClearance = "High Clearance"
    case passenger = "Passenger"
}
