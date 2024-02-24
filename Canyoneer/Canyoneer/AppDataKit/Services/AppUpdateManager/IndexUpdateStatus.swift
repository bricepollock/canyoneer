//  Created by Brice Pollock for Canyoneer on 2/19/24

import Foundation

enum IndexUpdateStatus: Codable, Equatable {
    static func == (lhs: IndexUpdateStatus, rhs: IndexUpdateStatus) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success):
            return true
        case (.failure(error: let lhsError), .failure(error: let rhsError)):
            return lhsError.code == rhsError.code
        default:
            return false
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case error
    }
    
    case success
    case failure(error: IndexUpdateError)
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let lastError = try? values.decode(IndexUpdateError.self, forKey: .error) {
            self = .failure(error: lastError)
        } else {
            self = .success
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .success:
            break // no-op
        case .failure(let error):
            try container.encode(error, forKey: .error)
        }
    }
}
