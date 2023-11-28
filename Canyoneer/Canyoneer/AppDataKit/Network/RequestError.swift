//
//  RequestError.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

enum RequestError: Error {
    case badRequest
    case badResponse
    case httpStatusCodeError
    case serialization
    case noResponse
}
