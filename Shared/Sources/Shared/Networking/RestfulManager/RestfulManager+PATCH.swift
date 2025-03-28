//
//  RestfulManager+PATCH.swift
//  
//
//  Created by Daniel Nugraha on 11.07.21.
//

import Foundation
import Combine

extension RestfulManager {
    /// Creates an `Element`s to a `URL` specified by `route`
    /// - Parameters:
    ///     - element: The `Element` that should be created
    ///     - route: The route to get the `Element`s from
    ///     - authorization: Whether the request should be authorized with an access token or not
    /// - Returns: An `AnyPublisher` that contains the created `Element` from the server or an `Error` in the case of an error
    static func patchElement<Element: Codable, Response: Decodable>(
        _ element: Element,
        authorization: Bool = true,
        on route: String
    ) -> AnyPublisher<Response, ServiceError> {
        executeRequest(
            url: buildURLRequest("PATCH",
                                 url: route,
                                 authorization: authorization,
                                 body: try? RestfulManager.getEncoder().encode(element))
        )
    }
}
