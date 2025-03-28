//
//  PostTrainingZones.swift
//  
//
//  Created by Daniel Nugraha on 22.06.21.
//

import Foundation


public struct PostTrainingZonesMediator: Codable {
    let patientId: Int
    let workoutType: Int
    let unit: String
    let upper0Bound: Int
    let upper1Bound: Int
    let upper2Bound: Int
    let upper3Bound: Int
    
    public init(patientId: Int, workoutType: Int, unit: String, values: [Int]) {
        precondition(values.count == 4)
        self.patientId = patientId
        self.workoutType = workoutType
        self.unit = unit
        upper0Bound = values[0]
        upper1Bound = values[1]
        upper2Bound = values[2]
        upper3Bound = values[3]
    }
}

public struct PostTrainingZonesResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case trainingZonesId = "patientTrainingZones"
    }
    
    public let trainingZonesId: Int
}

public struct DeleteTrainingZonesResponse: Codable {
    public let trainingZone: Int
}
