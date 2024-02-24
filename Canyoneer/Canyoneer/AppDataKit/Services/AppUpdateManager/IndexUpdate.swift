//  Created by Brice Pollock for Canyoneer on 2/19/24

import Foundation

struct IndexUpdate: Codable {
    enum CodingKeys: String, CodingKey {
        case time
        case status
    }
    
    let time: Date
    let status: IndexUpdateStatus
    
    init(
        time: Date = Date(),
        status: IndexUpdateStatus
    ) {
        self.time = time
        self.status = status
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let timestamp = try values.decode(Double.self, forKey: .time)
        time = Date(timeIntervalSince1970: timestamp)
        status = try values.decode(IndexUpdateStatus.self, forKey: .status)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(time.timeIntervalSince1970, forKey: .time)
        try container.encode(status, forKey: .status)
    }
}
