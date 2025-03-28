//
//  Rating+Helper.swift
//  
//
//  Created by Christopher Schütz on 20.06.21.
//

import Foundation

/// Mediator Object for a response provided after successful POST on /workout/rating
public struct PostRatingResponse: Codable {
    public let rating: Int
}
