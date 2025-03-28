//
//  Steps.swift
//  
//
//  Created by Christopher Schütz on 13.07.21.
//

import Foundation

public struct PostStepMediator: Codable {
    public let date: String // format: YYYY-MM-DD
    public let amount: UInt

    public init(date: String, amount: UInt) {
        self.date = date
        self.amount = amount
    }
}

public struct PostStepResponseMediator: Codable {
    let stepId: Int
    
    enum CodingKeys: String, CodingKey {
        case stepId = "steps"
    }
}

public struct GetStepMediator: Codable {
    public let amount: Int
    public let date: Date
    public let id: Int
    public let patientId: Int
    
    public init(amount: Int, date: Date, id: Int, patientId: Int) {
        self.amount = amount
        self.date = date
        self.id = id
        self.patientId = patientId
    }
}
