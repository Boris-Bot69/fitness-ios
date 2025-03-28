//
//  GetPatient.swift
//  
//
//  Created by Christopher Schütz on 12.07.21.
//

import Foundation

/// Mediator Object for  a get patient request
public struct GetPatientMediator: Codable {
    public let id: Int
    public let accountId: Int
    public let treatmentStarted: Date
    public let treatmentFinished: Date
    public let treatmentGoal: String
    public let height: Int?
    public let weight: Float?
    public let gender: String?
    public let comment: String?
}
