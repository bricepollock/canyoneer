//  Created by Brice Pollock for Canyoneer on 12/17/23

import Foundation

struct CanyonAPIURL {
    private static let host = "canyoneer--main.s3.us-west-1.amazonaws.com"
    private static let supportedVersion = "v2"

    static var index: URL {
        return URL(string: "https://\(host)/\(supportedVersion)/index.json")!
    }
    
    static func canyon(with id: String) -> URL {
        return URL(string: "https://\(host)/\(supportedVersion)/details/\(id).json")!
    }
}
