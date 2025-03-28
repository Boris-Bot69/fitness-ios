//
//  RestfulManager+GET.swift
//  
//
//  Created by Christopher Schütz on 04.07.21.
//

import Combine
import Foundation

extension RestfulManager {
    /// Gets a single `Element` from a `URL` specified by `route`
    /// - Parameters:
    ///     - route: The route to get the `Element` from
    ///     - authorization: Whether the request should be authorized with an access token or not
    /// - Returns: An `AnyPublisher` that contains the `Element` from the server or or an `Error` in the case of an error
    static func getElement<Response: Decodable>(
        on route: String,
        authorization: Bool = true,
        query: String?
    ) -> AnyPublisher<Response, ServiceError> {
        executeRequest(url: buildURLRequest("GET", url: route, authorization: authorization, query: query))
    }
    /// Gets a list of `Element`s from a `URL` specified by `route`
    /// - Parameters:
    ///     - route: The route to get the `Element`s from
    ///     - authorization: The `String` that should written in the `Authorization` header field
    /// - Returns: An `AnyPublisher` that contains an `Array` of  `Element` from the server or an empty `Array` in the case of an error
    static func getElements<Response: Codable>(
        on route: String,
        authorization: Bool = true,
        query: String?
    ) -> AnyPublisher<[Response], ServiceError> {
        getElement(on: route, authorization: authorization, query: query)
    }
}
