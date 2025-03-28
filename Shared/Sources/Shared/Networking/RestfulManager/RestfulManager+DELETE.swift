//
//  RestfulManager+DELETE.swift
//  
//
//  Created by Daniel Nugraha on 05.07.21.
//

import Foundation
import Combine

extension RestfulManager {
    /// Gets a single `Element` from a `URL` specified by `route`
    /// - Parameters:
    ///     - route: The route to get the `Element` from
    ///     - authorization: Whether the request should be authorized with an access token or not
    /// - Returns: An `AnyPublisher` that contains the `Element` from the server or or an `Error` in the case of an error
    static func deleteElement<Response: Decodable>(
        on route: String,
        authorization: Bool = true,
        query: String?
    ) -> AnyPublisher<Response, ServiceError> {
        executeRequest(
            url: buildURLRequest("DELETE",
                                 url: route,
                                 authorization: authorization,
                                 query: query)
        )
    }
}
