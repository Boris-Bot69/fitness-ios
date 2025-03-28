//
//  WorkoutService.swift
//  
//
//  Created by Christopher Schütz on 04.06.21.
//

import Foundation
import Combine

// MARK: WorkoutService
/// Service class for sending requests to workout endpoints
public class WorkoutService: BaseService {
    /// initialize AccountService with `/workout` prefix
    override public init() {
        super.init()
        self.prefixPath = "/workout"
    }
    
    // MARK: GET /workout
    /// publishes a GET request for a GetWorkoutMediator
    /// - Parameters
    ///     - identifier: id of the workout
    ///     - sampleRate: timeframe to which samples are aggregated, defaults to 10
    public func getWorkout(
        identifier: Int,
        sampleRate: Int = 10
    ) -> AnyPublisher<GetWorkoutMediator, ServiceError> {
        RestfulManager.getElement(
            on: self.baseUrl,
            query: "id=\(identifier)&sampleRate=\(sampleRate)"
        )
    }
    
    // MARK: POST /workout
    /// publishes a POST request with an postWorkoutMediator payload in the body
    /// - Parameters
    ///     - postWorkout: PostWorkoutMediator to be sent in the body
    public func postWorkout(
        _ postWorkout: PostWorkoutMediator
    ) -> AnyPublisher<PostWorkoutResponse, ServiceError> {
        let requestPayload = HealthJsonDataResponse(healthJsonData: postWorkout)
        
        return RestfulManager.postElement(
            requestPayload,
            on: self.baseUrl
        )
    }
    
    // MARK: GET /workout/overviews
    /// publishes a GET request to /workout/overviews
    /// - Parameters
    ///     - start: start date of workouts that should be considered for the overview
    ///     - end: end date of workouts that should be considered for the overview
    public func getWorkoutsOverview(
        start startDate: Date,
        end endDate: Date,
        patientId: Int? = nil
    ) -> AnyPublisher<WorkoutsOverviewMediator, ServiceError> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var query = "fromDate=\(dateFormatter.string(from: startDate))&toDate=\(dateFormatter.string(from: endDate))"
        
        if let patientId = patientId {
            query += "&patientId=\(patientId)"
        }
        
        return RestfulManager.getElement(
            on: self.baseUrl + "/overviews",
            query: query
        )
    }
    
    // MARK: POST /workout/rating
    /// publishes a POST request with a postRatingMediator payload in the body
    /// - Parameters
    ///     - postRating: PostRatingMediator to be sent in the body
    public func postRating(
        _ postRating: PostRatingMediator
    ) -> AnyPublisher<PostRatingResponse, ServiceError> {
        RestfulManager.postElement(
            postRating,
            on: self.baseUrl + "/rating"
        )
    }
    
    // MARK: POST /workout/steps
    /// Publishes a POST Request with a PostStepMediator in the body
    /// - Parameters
    ///     - postSteps: PostStepMediator to be sent in the body
    public func postSteps(
        _ postSteps: PostStepMediator
    ) -> AnyPublisher<PostStepResponseMediator, ServiceError> {
        RestfulManager.postElement(
            postSteps,
            on: self.baseUrl + "/steps"
        )
    }
}
