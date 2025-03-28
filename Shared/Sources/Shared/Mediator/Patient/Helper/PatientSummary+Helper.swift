//
//  PatientSummary+Helper.swift
//  
//
//  Created by Christopher Schütz on 18.06.21.
//

import Foundation

public class PatientTrainingZoneProfile: Codable {
    public let zone0: Double
    public let zone1: Double
    public let zone2: Double
    public let zone3: Double
    public let zone4: Double
    
    public init(
        zone0: Double,
        zone1: Double,
        zone2: Double,
        zone3: Double,
        zone4: Double
    ) {
        self.zone0 = zone0
        self.zone1 = zone1
        self.zone2 = zone2
        self.zone3 = zone3
        self.zone4 = zone4
    }
}

public class PatientHeartRateProfile: PatientTrainingZoneProfile {}

public class PatientSpeedProfile: PatientTrainingZoneProfile {}

public class PatientTrainingIntervalProfile: Codable {
    public let id: Int
    public let workoutType: Int
    public let unit: String
    public let upper0Bound: Int
    public let upper1Bound: Int
    public let upper2Bound: Int
    public let upper3Bound: Int
    
    public init(
        id: Int,
        workoutType: Int,
        unit: String,
        upper0Bound: Int,
        upper1Bound: Int,
        upper2Bound: Int,
        upper3Bound: Int
    ) {
        self.id = id
        self.workoutType = workoutType
        self.unit = unit
        self.upper0Bound = upper0Bound
        self.upper1Bound = upper1Bound
        self.upper2Bound = upper2Bound
        self.upper3Bound = upper3Bound
    }
}

extension PatientTrainingZoneProfile: Comparable {
    public static func < (lhs: PatientTrainingZoneProfile, rhs: PatientTrainingZoneProfile) -> Bool {
        lhs.zone4 > rhs.zone4
    }
    
    public static func == (lhs: PatientTrainingZoneProfile, rhs: PatientTrainingZoneProfile) -> Bool {
        lhs.zone0 == rhs.zone0 && lhs.zone1 == rhs.zone1 && lhs.zone2 == rhs.zone2
            && lhs.zone3 == rhs.zone3 && lhs.zone4 == rhs.zone4
    }
}

public class RatingAmounts: Codable {
    public let bad: Int
    public let good: Int
    public let medium: Int
    public let unrated: Int
    
    public init(bad: Int, good: Int, medium: Int, unrated: Int) {
        self.bad = bad
        self.good = good
        self.medium = medium
        self.unrated = unrated
    }
}

extension RatingAmounts: Comparable {
    //ascending means most red to least red
    public static func < (lhs: RatingAmounts, rhs: RatingAmounts) -> Bool {
        let lhsTotal = lhs.bad + lhs.good + lhs.medium
        let rhsTotal = rhs.bad + rhs.good + rhs.medium
        if lhsTotal > 0 && rhsTotal > 0 {
            //check if lhs bad percentage > rhs bad percentage
            if Double(lhs.bad) / Double(lhsTotal) != Double(rhs.bad) / Double(rhsTotal) {
                return Double(lhs.bad) / Double(lhsTotal) > Double(rhs.bad) / Double(rhsTotal)
            //check if lhs medium percentage > rhs medium percentage
            } else if Double(lhs.medium) / Double(lhsTotal) != Double(rhs.medium) / Double(rhsTotal) {
                return Double(lhs.medium) / Double(lhsTotal) > Double(rhs.medium) / Double(rhsTotal)
            //check if lhs good percentage > rhs good percentage
            } else {
                return Double(lhs.good) / Double(lhsTotal) > Double(rhs.good) / Double(rhsTotal)
            }
        } else {
            //put all without rating to the bottom
            return lhsTotal > 0 ? true : false
        }
    }
    
    public static func == (lhs: RatingAmounts, rhs: RatingAmounts) -> Bool {
        lhs.bad == rhs.bad && lhs.medium == rhs.medium && lhs.good == rhs.good && lhs.unrated == rhs.unrated
    }
}

public class ProgressObject: Codable {
    public let completed: Int
    public let total: Int
    
    public init(completed: Int, total: Int) {
        self.completed = completed
        self.total = total
    }
}

extension ProgressObject: Comparable {
    public static func == (lhs: ProgressObject, rhs: ProgressObject) -> Bool {
        lhs.completed == rhs.completed && lhs.total == rhs.total
    }
    
    
    public static func < (lhs: ProgressObject, rhs: ProgressObject) -> Bool {
        if rhs.total == 0 {
            return false
        } else if lhs.total == 0 {
            return true
        } else {
            return lhs.completed / lhs.total < rhs.completed / rhs.total
        }
    }
}
