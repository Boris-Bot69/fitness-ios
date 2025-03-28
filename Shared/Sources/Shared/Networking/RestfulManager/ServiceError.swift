//
//  ServiceError.swift
//  
//
//  Created by Christopher Schütz on 04.07.21.
//

import Combine
import Foundation


// MARK: ServiceError
/// An `Error` that details possible errors that can occur when interacting with the Server
public enum ServiceError: LocalizedError, Equatable {
    case invalidRequest
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case error4xx(_ code: Int)
    case serverError
    case error5xx(_ code: Int)
    case decodingError
    case urlSessionFailed(_ error: URLError)
    case badURL
    case unknownError
}
