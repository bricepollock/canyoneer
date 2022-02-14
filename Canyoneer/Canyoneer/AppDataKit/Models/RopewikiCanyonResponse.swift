//
//  RopewikiCanyonResponse.swift
//  Canyoneer
//
//  Created by Brice Pollock on 2/9/22.
//

import Foundation

struct RopewikiCanyonResponse: Codable {
    let parse: RopewikiCanyonParse
}

struct RopewikiCanyonParse: Codable {
    let title: String
    let text: [String: String] // "*": "{{<structured_data>}}<html>"
}
