//  Created by Brice Pollock for Canyoneer on 12/17/23

import Foundation

struct CanyonAPIURL {
    private static let host = "canyoneer-api.s3.us-west-1.amazonaws.com"

    static var index: URL {
        return URL(string: "https://\(host)/index.json")!
    }
    
    static func canyon(with id: String) -> URL {
        return URL(string: "https://\(host)/routes/\(id).json")!
    }
}
