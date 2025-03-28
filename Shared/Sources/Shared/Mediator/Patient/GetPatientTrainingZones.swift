//
//  GetPatientTrainingZones.swift
//  
//
//  Created by Denis Graipel on 16.07.21.
//

import Foundation

public struct GetTrainingZonesMediator: Codable {
    public let trainingZones: [PatientTrainingZone]
}

public struct PatientTrainingZone: Codable {
    public let workoutType: Int
    public let unit: String
    public let upper0Bound: Int
    public let upper1Bound: Int
    public let upper2Bound: Int
    public let upper3Bound: Int
}
