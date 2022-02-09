//
//  RequestError.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

enum RequestError: Error {
    
    case noResponse
    case badResponse
    case badRequest
    case serialization
    case http(code: Int)
    
    func description() -> String {
        switch self {
        case .noResponse: return "No HTTP response received"
        case .badResponse: return "Non HTTP response received"
        case .badRequest: return "Bad Request"
        case .serialization: return "Deserialization failure!"
        case .http(let code): return "Encountered HTTP Error \(code)"
        }
        
    }
}
