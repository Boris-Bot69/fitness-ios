//
//  File.swift
//  
//
//  Created by Daniel Nugraha on 11.07.21.
//

import Foundation

/// Mediator Object for  a single patch patient
public struct PatchPatientMediator: Codable {
    let id: Int
    let accountId: Int?
    let treatmentStarted: String?
    let treatmentFinished: String?
    let treatmentGoal: String?
    let height: Int?
    let weight: Float?
    let gender: String?
    let comment: String?
    
    public init(
        id: Int,
        accountId: Int? = nil,
        treatmentStarted: String? = nil,
        treatmentFinished: String? = nil,
        treatmentGoal: String? = nil,
        height: Int? = nil,
        weight: Float? = nil,
        gender: String? = nil,
        comment: String? = nil
    ) {
        self.id = id
        self.accountId = accountId
        self.treatmentStarted = treatmentStarted
        self.treatmentFinished = treatmentFinished
        self.treatmentGoal = treatmentGoal
        self.height = height
        self.weight = weight
        self.comment = comment
        
        let string = Gender(rawValue: gender ?? "") ?? .none
        
        switch string {
        case .male:
            self.gender = "m"
        case .female:
            self.gender = "f"
        case .diverse:
            self.gender = "d"
        case .none:
            self.gender = nil
        }
    }
}
