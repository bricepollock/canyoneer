//
//  RequestError.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

enum RequestError: Error {
    
    case badRequest
    case serialization
    
    func description() -> String {
        switch self {
        case .badRequest: return "Bad Request"
        case .serialization: return "Deserialization failure!"
        }
        
    }
}
