//  Created by Brice Pollock for Canyoneer on 2/17/24

import Foundation

extension DateComponentsFormatter {
    static let durationFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    static func duration(for seconds: TimeInterval) -> String {
        DateComponentsFormatter.durationFormatter.string(from: seconds) ?? "\(seconds)s"
    }
}
