//
//  PlanningService.swift
//  
//
//  Created by Christopher Schütz on 08.07.21.
//

import Combine
import Foundation

// MARK: PlanningService
/// Service class for sending requests to planning endpoints
public class PlanningService: BaseService {
    /// initialize PlanningService with `/planning` prefix
    override public init() {
        super.init()
        self.prefixPath = "/planning"
    }
    
    // MARK: POST /planning/import
    /// publishes a POST request with a trainingPlan file as data payload in the body
    /// - Parameters
    ///     - payload: CSV File Training Plan encoded as Data
    public func uploadTrainingPlan(
        _ payload: TrainingPlanPostMediator
    ) -> AnyPublisher<TrainingPlanResponseMediator, ServiceError> {
        RestfulManager.postElement(
            payload,
            on: self.baseUrl + "/import"
        )
    }
}
