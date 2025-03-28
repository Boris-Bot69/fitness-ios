//
//  PatientSummary.swift
//
//
//  Created by Christopher Schütz on 16.06.21.
//

import Foundation

/// Mediator Object for  a SINGLE element in the array response provided by the endpoint /patient/overviews
public class PatientSummary: Codable {
    public let id: Int
    public let accountId: Int
    public let active: Bool
    public let birthday: Date
    public let firstName: String
    public let heartRateProfileRunning: PatientHeartRateProfile
    public let heartRateProfileCycling: PatientHeartRateProfile
    public let lastName: String
    public let lastTraining: Date?
    public let totalHours: Double
    public let ratings: RatingAmounts
    public let studyGroups: [String]
    public let trainingProgress: ProgressObject
    public let treatmentFinished: Date?
    public let treatmentStarted: Date
    public let weekProgress: ProgressObject
    public let email: String?
    public let username: String
    public let treatmentGoal: String
    public let trainingZoneIntervals: [PatientTrainingIntervalProfile]
    public let weight: Float?
    public let gender: String?
    public let height: Int?
    public let comment: String?

    public init(
        accountId: Int,
        active: Bool,
        birthday: Date,
        firstName: String,
        heartRateProfileRunning: PatientHeartRateProfile,
        heartRateProfileCycling: PatientHeartRateProfile,
        id: Int,
        lastName: String,
        lastTraining: Date?,
        ratings: RatingAmounts,
        studyGroups: [String],
        trainingProgress: ProgressObject,
        treatmentFinished: Date,
        treatmentStarted: Date,
        weekProgress: ProgressObject,
        totalHours: Double,
        email: String,
        username: String,
        treatmentGoal: String,
        trainingZoneIntervals: [PatientTrainingIntervalProfile],
        weight: Float? = nil,
        gender: String? = nil,
        height: Int? = nil,
        comment: String? = nil
    ) {
        self.accountId = accountId
        self.active = active
        self.birthday = birthday
        self.firstName = firstName
        self.heartRateProfileRunning = heartRateProfileRunning
        self.heartRateProfileCycling = heartRateProfileCycling
        self.id = id
        self.lastName = lastName
        self.lastTraining = lastTraining
        self.ratings = ratings
        self.studyGroups = studyGroups
        self.trainingProgress = trainingProgress
        self.treatmentFinished = treatmentFinished
        self.treatmentStarted = treatmentStarted
        self.weekProgress = weekProgress
        self.totalHours = totalHours
        self.email = email
        self.username = username
        self.treatmentGoal = treatmentGoal
        self.trainingZoneIntervals = trainingZoneIntervals
        self.weight = weight
        self.gender = gender
        self.height = height
        self.comment = comment
    }
}

extension PatientSummary: Equatable {
    public static func == (lhs: PatientSummary, rhs: PatientSummary) -> Bool {
        lhs.accountId == rhs.accountId && lhs.id == rhs.id
    }
}

extension PatientSummary: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(accountId)
    }
}

/// Mediator Object for  a single patient export
public class PatientExportMediator: Codable {
    let patientIds: [Int]
    let fromDate: Date?
    let toDate: Date?
    
    public init(_ patientIds: [Int], fromDate: Date?, toDate: Date?) {
        self.patientIds = patientIds
        self.fromDate = fromDate
        self.toDate = toDate
    }
}

/// Mediator Object for  a patient export request
public class PatientExport: Codable {
    public let overview: String
    public let patientId: Int
}
