//  Created by Brice Pollock for Canyoneer on 2/17/24

import Foundation

enum IndexUpdateError: Error {
    /// An unexpected error was thrown
    case unknown(String)
    /// Network failure trying to get new database index file
    case indexRequest(String)
    /// Serialization error trying to unpack new database index file
    case indexRequestDecoding(String)
    /// Failure to read or write one of the canyon summaries identified as stale in index update
    case singleCanyonUpdate(String)
    /// Failure to write the new index to disk
    case indexFileWrite(String)
    
    init(code: Int, details: String) {
        switch code {
        case 1200:
            self = .unknown(details)
        case 1201:
            self = .indexRequest(details)
        case 1202:
            self = .indexRequestDecoding(details)
        case 1203:
            self = .singleCanyonUpdate(details)
        case 1204:
            self = .indexFileWrite(details)
        default:
            self = .unknown(details)
        }
    }
        
    /// A specialized app-defined error code
    var code: Int {
        switch self {
        case .unknown:
            return 1200
        case .indexRequest:
            return 1201
        case .indexRequestDecoding:
            return 1202
        case .singleCanyonUpdate:
            return 1203
        case .indexFileWrite:
            return 1204
        }
    }
    /// Human readable message regarding failure
    var humanMessage: String {
        switch self {
        case .unknown:
            return "Unexpected failure".capitalized
        case .indexRequest:
            return "Update request failure".capitalized
        case .indexRequestDecoding:
            return "Update read failure".capitalized
        case .singleCanyonUpdate:
            return "Canyon update failure".capitalized
        case .indexFileWrite:
            return "Write update failure".capitalized
        }
    }
    
    /// Debug message containing as much information as possible
    var debugDetails: String {
        switch self {
        case .unknown(let details), .indexRequest(let details), .indexRequestDecoding(let details), .singleCanyonUpdate(let details), .indexFileWrite(let details):
            if details.hasPrefix(humanMessage) {
                return details
            } else {
                return "\(humanMessage): \(details)"
            }            
        }
    }
}

extension IndexUpdateError: Codable {
    enum CodingKeys: String, CodingKey {
        case code
        case details
    }
        
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let code = try values.decode(Int.self, forKey: .code)
        let details = try values.decode(String.self, forKey: .details)
        self.init(code: code, details: details)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(debugDetails, forKey: .details)
    }
}
