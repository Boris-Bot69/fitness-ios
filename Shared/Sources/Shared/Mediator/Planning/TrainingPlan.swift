//
//  TrainingPlan.swift
//  
//
//  Created by Christopher Schütz on 08.07.21.
//

import Foundation

public struct TrainingPlanPostMediator: Codable {
    public let patientId: Int
    public let xlsxBase64: String
    
    public init(patientId: Int, xlsxBase64: String) {
        self.patientId = patientId
        self.xlsxBase64 = xlsxBase64
    }
}

public struct TrainingPlanResponseMediator: Codable {
    let plannedWorkouts: [Int]
}
