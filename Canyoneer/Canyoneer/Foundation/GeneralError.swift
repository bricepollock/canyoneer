//
//  GeneralError.swift
//  Canyoneer
//
//  Created by Brice Pollock on 11/27/23.
//

import Foundation

enum GeneralError: Error {
    case notFound
    case canceled
    case permissionsDenied
    case unknownFailure
}
