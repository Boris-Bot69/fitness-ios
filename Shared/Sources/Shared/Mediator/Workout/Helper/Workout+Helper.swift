//
//  Workout+Helper.swift
//  
//
//  Created by Christopher Schütz on 18.06.21.
//

import Foundation

/// Mediator Object for a response provided after successful POST on /workout
public class PostWorkoutResponse: Codable {
    public let workout: Int
}

public class CombinedProfileSample: Codable {
    public let altitude: Double?
    public let distance: Double?
    public let heartRate: Double?
    public let secondsSinceStart: Double
    public let speed: Double?
    
    public init(
        altitude: Double?,
        distance: Double?,
        heartRate: Double?,
        secondsSinceStart: Double,
        speed: Double?
    ) {
        self.altitude = altitude
        self.distance = distance
        self.heartRate = heartRate
        self.secondsSinceStart = secondsSinceStart
        self.speed = speed
    }
}

public class KilometerPaceSample: Codable {
    public let kilometre: Int
    public let minutes: Int
    public let seconds: Double
    public let avgHeartRate: Double?
    public let avgSpeed: Double?
    public let maxHeartRate: Double?
    public let maxSpeed: Double?
    
    public init(
        kilometre: Int,
        minutes: Int,
        seconds: Double,
        avgHeartRate: Double,
        avgSpeed: Double,
        maxHeartRate: Double,
        maxSpeed: Double
    ) {
        self.kilometre = kilometre
        self.minutes = minutes
        self.seconds = seconds
        self.avgHeartRate = avgHeartRate
        self.avgSpeed = avgSpeed
        self.maxHeartRate = maxHeartRate
        self.maxSpeed = maxSpeed
    }
}

public class TrainingZone: Codable {
    public let total: Int
    public let zone0: Int
    public let zone1: Int
    public let zone2: Int
    public let zone3: Int
    public let zone4: Int
    
    public init(
        total: Int,
        zone0: Int,
        zone1: Int,
        zone2: Int,
        zone3: Int,
        zone4: Int
        ) {
        self.total = total
        self.zone0 = zone0
        self.zone1 = zone1
        self.zone2 = zone2
        self.zone3 = zone3
        self.zone4 = zone4
    }
}

public class TrainingZones: Codable {
    public let heartRate: TrainingZone?
    public let speed: TrainingZone?
    
    public init(
        heartRate: TrainingZone,
        speed: TrainingZone
    ) {
        self.heartRate = heartRate
        self.speed = speed
    }
}

public struct PostEvent: Codable {
    public let start: String
    public let end: String
    public let duration: Double
    public let type: String
    
    public init(start: String, end: String, duration: Double, type: String) {
        self.start = start
        self.end = end
        self.duration = duration
        self.type = type
    }
}

public struct PostHeartRateSample: Codable {
    public let startTime: String
    public let endTime: String
    public let quantity: PostHeartRateQuantity
    public let count: Int
    public let device: String
    
    public init(
        startTime: String,
        endTime: String,
        quantity: PostHeartRateQuantity,
        count: Int,
        device: String
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.quantity = quantity
        self.count = count
        self.device = device
    }
}

public struct PostHeartRateQuantity: Codable {
    public let doubleValue: Double
    public let unit: String
    
    public init(
        doubleValue: Double,
        unit: String
    ) {
        self.doubleValue = doubleValue
        self.unit = unit
    }
}

public struct PostWorkoutRouteSample: Codable { }

public struct PostDistanceWalkingRunningQuantity: Codable {
    public let doubleValue: Double
    public let unit: String
    
    public init(
        doubleValue: Double,
        unit: String
    ) {
        self.doubleValue = doubleValue
        self.unit = unit
    }
}

public struct PostDistanceWalkingRunningSample: Codable {
    public let startTime: String
    public let endTime: String
    public let quantity: PostDistanceWalkingRunningQuantity
    public let count: Int
    public let device: String
    
    public init(startTime: String, endTime: String, quantity: PostDistanceWalkingRunningQuantity, count: Int, device: String) {
        self.startTime = startTime
        self.endTime = endTime
        self.quantity = quantity
        self.count = count
        self.device = device
    }
}

public struct DistanceWalkingRunningQuantity: Codable {
    public let doubleValue: Double
    public let unit: String
}

public struct HealthJsonDataResponse: Codable {
    public init(healthJsonData: PostWorkoutMediator) {
        self.healthJsonData = healthJsonData
    }
    
    public let healthJsonData: PostWorkoutMediator
}

public struct PostUnitObject: Codable {
    public let doubleValue: Double
    public let unit: String
    
    public init(doubleValue: Double, unit: String) {
        self.doubleValue = doubleValue
        self.unit = unit
    }
}
