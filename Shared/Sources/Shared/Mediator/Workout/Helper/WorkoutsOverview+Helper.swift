//
//  WorkoutsOverview+Helper.swift
//  
//
//  Created by Christopher Schütz on 18.06.21.
//

import Foundation
import HealthKit
import FontAwesomeSwiftUI

public class WorkoutsOverviewWorkoutMediator: Codable {
    public let workoutId: Int
    public let appleUUID: String
    public let duration: Double
    public let startTime: Date
    public let type: Int
    public let mainHeartRateSegment: Int?
    public var rating: Int
    public var comment: String
    public var intensity: Double
    public let distance: Double
    public let calories: Double
    
    public init(
        workoutId: Int,
        appleUUID: String,
        duration: Double,
        startTime: Date,
        type: Int,
        mainHeartRateSegment: Int,
        rating: Int,
        comment: String,
        intensity: Double,
        distance: Double,
        calories: Double
    ) {
        self.workoutId = workoutId
        self.appleUUID = appleUUID
        self.duration = duration
        self.startTime = startTime
        self.type = type
        self.mainHeartRateSegment = mainHeartRateSegment
        
        self.rating = rating
        self.comment = comment
        self.intensity = intensity
        
        self.distance = distance
        self.calories = calories
    }
    
    public var activityType: HKWorkoutActivityType {
        HKWorkoutActivityType(rawValue: UInt(type)) ?? HKWorkoutActivityType.other
    }
}

public class PlannedWorkout: Codable, Hashable, Equatable {
    public var id: Int //id of planned workout
    public var patientId: Int
    public var type: Int
    public var maxHeartRate: Int?
    public var minDistance: Int?
    public var minDuration: Int?
    public var plannedDate: Date
    
    public init(
        id: Int,
        patientId: Int,
        type: Int,
        maxHeartRate: Int,
        minDistance: Int,
        minDuration: Int,
        plannedDate: Date
    ) {
        self.id = id
        self.patientId = patientId
        self.type = type
        self.maxHeartRate = maxHeartRate
        self.minDistance = minDistance
        self.minDuration = minDuration
        self.plannedDate = plannedDate
    }
    
    public var activityType: HKWorkoutActivityType {
        HKWorkoutActivityType(rawValue: UInt(type)) ?? HKWorkoutActivityType.other
    }
    
    public var activityIcon: String {
        WorkoutUtils.activityIcon(activityType)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: PlannedWorkout, rhs: PlannedWorkout) -> Bool {
        lhs.id == rhs.id
    }
}

public class ActivityOverview: Codable {
    public var distance: Double
    public var duration: Double
    public var heartRateTrainingZones: HeartRateZones
    public var trainingsDone: Int
    public var trainingsDue: Int
    
    public init(
        distance: Double,
        duration: Double,
        heartRateTrainingZones: HeartRateZones,
        trainingsDone: Int,
        trainingsDue: Int
    ) {
        self.distance = distance
        self.duration = duration
        self.heartRateTrainingZones = heartRateTrainingZones
        self.trainingsDone = trainingsDone
        self.trainingsDue = trainingsDue
    }
}

public class RunningOverview: ActivityOverview { }

public class CyclingOverview: ActivityOverview { }

public class HeartRateZones: Codable {
    public let total: Int
    public let zone0HeartRate: Int
    public let zone1HeartRate: Int
    public let zone2HeartRate: Int
    public let zone3HeartRate: Int
    public let zone4HeartRate: Int
    
    public init(
        total: Int,
        zone0HeartRate: Int,
        zone1HeartRate: Int,
        zone2HeartRate: Int,
        zone3HeartRate: Int,
        zone4HeartRate: Int
    ) {
        self.total = total
        self.zone0HeartRate = zone0HeartRate
        self.zone1HeartRate = zone1HeartRate
        self.zone2HeartRate = zone2HeartRate
        self.zone3HeartRate = zone3HeartRate
        self.zone4HeartRate = zone4HeartRate
    }

    public var zoneValues: [Int] {
        [
            self.zone0HeartRate,
            self.zone1HeartRate,
            self.zone2HeartRate,
            self.zone3HeartRate,
            self.zone4HeartRate
        ]
    }
}

/// sort workouts by date
extension WorkoutsOverviewWorkoutMediator: Comparable, Identifiable {
    public static func == (lhs: WorkoutsOverviewWorkoutMediator, rhs: WorkoutsOverviewWorkoutMediator) -> Bool {
        lhs.workoutId == rhs.workoutId
    }
    
    public static func < (lhs: WorkoutsOverviewWorkoutMediator, rhs: WorkoutsOverviewWorkoutMediator) -> Bool {
        lhs.startTime < rhs.startTime
    }
}

// MARK: View-related Extensions
extension WorkoutsOverviewWorkoutMediator {
    /// Distance-based workouts display other primary and secondary metrics
    var isDistanceBasedWorkout: Bool {
        [
            HKWorkoutActivityType.running,
            HKWorkoutActivityType.cycling,
            HKWorkoutActivityType.handCycling
        ].contains(activityType)
    }
    
    /// Return duration in `hh:mm:ss` format
    public var durationText: String {
        WorkoutUtils.formatDuration(time: duration, full: true)
    }
    
    /// Return workout duration in `hh:mm:ss` or `mm:ss` format (if duration is less than 1 hour)
    public var durationTextMinimal: String {
        WorkoutUtils.formatDuration(time: duration)
    }
    
    /// Returns distance for distance-based workouts, duration for others.
    public var primaryMetric: (String, String) {
        isDistanceBasedWorkout ? (String(format: "%.1f", distance / 1000), "km") : (durationText, "")
    }
    
    /// Return duration for distance-based workouts, burned calories for others.
    public var secondaryMetric: String {
        isDistanceBasedWorkout ? durationText : "\(Int(calories)) kcal"
    }
    
    /// Return FontAwesome icon string based on this workout's activityType
    public var activityIcon: String {
        WorkoutUtils.activityIcon(activityType)
    }

    /// Return date in a human-readable string relative to now
    ///
    /// Example: 45 minutes ago
    public var relativeDateDescription: String {
        if let diff = Calendar.current.dateComponents([.hour], from: startTime, to: Date()).hour, diff < 24 {
            return RelativeDateTimeFormatter.namedAndSpelledOut.localizedString(for: startTime, relativeTo: Date())
        }
        return DateFormatter.dateAndTime.string(from: startTime)
    }
}
