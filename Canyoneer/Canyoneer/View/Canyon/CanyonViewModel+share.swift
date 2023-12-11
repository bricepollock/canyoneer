//  Created by Brice Pollock for Canyoneer on 12/2/23

import Foundation
import UIKit

extension CanyonViewModel: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        guard let canyon = self.canyon else { return ""}
        return Strings.message(for: canyon)
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let canyon = self.canyon else { return nil }
        if activityType == .mail {
            return Strings.body(for: canyon)
        } else {
            return Strings.message(for: canyon)
        }
        
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        guard let canyon = self.canyon else { return "" }
        return Strings.subject(name: canyon.name)
    }
    
    internal enum Strings {
        static let canyon = "Canyon Details"
        static func message(for canyon: Canyon) -> String {
            var message = "I found '\(canyon.name) \(canyon.technicalSummary)' on the 'Canyoneer' app."
            if let ropeWikiString = canyon.ropeWikiURL?.absoluteString {
                message += " Check out the canyon on Ropewiki: \(ropeWikiString)"
            }
            return message
        }
        
        static func subject(name: String) -> String {
            return "Check out this cool canyon: \(name)"
        }
        
        static func body(for canyon: Canyon) -> String {
            var body = "I found '\(canyon.name) \(canyon.technicalSummary)' on the 'Canyoneer' app."
            if let ropeWikiString = canyon.ropeWikiURL?.absoluteString {
                body += " Check out the canyon on Ropewiki: \(ropeWikiString)"
            }
            return body
        }
    }
}

