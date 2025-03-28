//
//  StudyGroup.swift
//  
//
//  Created by Daniel Nugraha on 27.06.21.
//

import Foundation

/// Mediator Object for  a post study group request
public struct StudyGroup: Codable {
    enum CodingKeys: String, CodingKey {
        case studyGroupId = "id"
        case name
    }
    
    public init(name: String, studyGroupId: Int) {
        self.name = name
        self.studyGroupId = studyGroupId
    }
    
    public let name: String
    public let studyGroupId: Int
}
/// Mediator Object for  a post study group member request
public struct PostStudyGroupMemberMediator: Codable {
    public let studyGroupId: Int
    public let patientId: Int
    
    public init(_ studyGroupId: Int, patientId: Int) {
        self.studyGroupId = studyGroupId
        self.patientId = patientId
    }
}

/// Mediator Object for  a post study group trainer request
public struct PostStudyGroupTrainerMediator: Codable {
    public let studyGroupId: Int
    public let trainerId: Int
    
    public init(_ studyGroupId: Int, trainerId: Int) {
        self.studyGroupId = studyGroupId
        self.trainerId = trainerId
    }
}
/// Mediator Object for  a post study group request
public struct PostStudyGroupMediator: Codable {
    public let name: String
    
    public init(_ name: String) {
        self.name = name
    }
}

/// Mediator Object for  a post study group
public struct PostStudyGroupResponse: Codable {
    public let studyGroup: Int
}

/// Mediator Object for  a post study group member
public struct PostStudyGroupMemberResponse: Codable {
    public let studyGroupMember: Int
    
    // dummy initializer
    public init() {
        self.studyGroupMember = -1
    }
}
/// Mediator Object for  a post study group trainer
public struct PostStudyGroupTrainerResponse: Codable {
    public let studyGroupTrainer: Int
}

extension StudyGroup: Hashable { }
