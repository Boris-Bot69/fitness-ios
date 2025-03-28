//
//  PostApiRating.swift
//  
//
//  Created by Christopher Schütz on 15.06.21.
//

import Foundation

/// Mediator Object for a workout rating required in the body of a POST request to endpoint /workout/rating
public struct PostRatingMediator: Codable {
    public let workoutId: Int
    public let rating: Int
    public let intensity: Int
    public let comment: String
    
    public init(workoutId: Int, rating: Int, intensity: Int, comment: String) {
        self.workoutId = workoutId
        self.rating = rating
        self.intensity = intensity
        self.comment = comment
    }
}
