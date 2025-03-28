//
//  PostPatient.swift
//  
//
//  Created by Daniel Nugraha on 22.06.21.
//

import Foundation
import SwiftUI

/// Mediator Object for  a post patient request
public struct PostPatientMediator: Codable {
    let accountId: Int
    let treatmentStarted: String
    let treatmentFinished: String
    let treatmentGoal: String
    let height: Int?
    let weight: Float?
    let gender: String?
    let comment: String?
    
    public init(
        accountId: Int,
        treatmentStarted: String,
        treatmentFinished: String,
        treatmentGoal: String,
        height: Int?,
        weight: Float?,
        gender: String?,
        comment: String?
    ) {
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
/// Mediator Object for  a post patient
public struct PostPatientResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case patientId = "patient"
    }
    
    public let patientId: Int
}

/// Gender enum
public enum Gender: String, Equatable, CaseIterable {
    case male
    case female
    case diverse
    
    public var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}
