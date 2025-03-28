//
//  PostApiWorkout.swift
//  
//
//  Created by Christopher Schütz on 07.06.21.
//

import Foundation

/// Mediator Object for a workout in the response provided by the GET endpoint /workout
public class GetWorkoutMediator: Codable {
    public let id: Int
    public let comment: String?
    public let distance: Double?
    public let duration: Double
    public let endTime: Date
    public let heartRateAverage: Double?
    public let heartRateMaximum: Double?
    public let heartRateMinimum: Double?
    public let intensity: Int
    public let kcal: Int
    public let kilometerPace: [KilometerPaceSample]
    public let paceMaximum: Double?
    public let paceMinimum: Double?
    public let rating: Int
    public let speedAverage: Double?
    public let speedMaximum: Double?
    public let speedMinimum: Double?
    public let startTime: Date
    public let terrainDown: Double?
    public let terrainUp: Double?
    public let trainingZones: TrainingZones
    public let type: Int
    public let combinedProfiles: [CombinedProfileSample]
    
    enum CodingKeys: String, CodingKey {
        case id
        case comment
        case distance
        case duration
        case endTime
        case heartRateAverage = "heartRateAvg"
        case heartRateMaximum = "heartRateMax"
        case heartRateMinimum = "heartRateMin"
        case intensity
        case kcal
        case kilometerPace
        case paceMaximum = "paceMax"
        case paceMinimum = "paceMin"
        case rating
        case speedAverage = "speedAvg"
        case speedMaximum = "speedMax"
        case speedMinimum = "speedMin"
        case startTime
        case terrainDown
        case terrainUp
        case trainingZones
        case type
        case combinedProfiles
    }
    
    public init(
        id: Int,
        dayOfWorkout: String,
        timeWorkoutWasStarted: String,
        comment: String?,
        distance: Double?,
        distanceRounded: Int,
        duration: Double,
        endTime: Date,
        heartRateAverage: Double?,
        heartRateMaximum: Double?,
        heartRateMinimum: Double?,
        intensity: Int,
        kcal: Int,
        kilometerPace: [KilometerPaceSample],
        paceMaximum: Double?,
        paceMinimum: Double?,
        rating: Int,
        speedAverage: Double?,
        speedMaximum: Double?,
        speedMinimum: Double?,
        startTime: Date,
        terrainDown: Double,
        terrainUp: Double,
        trainingZones: TrainingZones,
        type: Int,
        combinedProfiles: [CombinedProfileSample]
    ) {
        self.id = id
        self.comment = comment
        self.distance = distance
        self.duration = duration
        self.endTime = endTime
        self.heartRateAverage = heartRateAverage
        self.heartRateMaximum = heartRateMaximum
        self.heartRateMinimum = heartRateMinimum
        self.intensity = intensity
        self.kcal = kcal
        self.kilometerPace = kilometerPace
        self.paceMaximum = paceMaximum
        self.paceMinimum = paceMinimum
        self.rating = rating
        self.speedAverage = speedAverage
        self.speedMaximum = speedMaximum
        self.speedMinimum = speedMinimum
        self.startTime = startTime
        self.terrainDown = terrainDown
        self.terrainUp = terrainUp
        self.trainingZones = trainingZones
        self.type = type
        self.combinedProfiles = combinedProfiles
    }
}

extension GetWorkoutMediator {
    /// get day of workout string
    public var dayOfWorkout: String {
        let dateFormatter = DateFormatter()
        var date = "00.00.0000"
        date = dateFormatter.string(from: self.startTime)
        return date
    }
    
    /// get time workout was started string
    public var timeWorkoutWasStarted: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "H:m"
        var time = "00:00"
        
        time = timeFormatter.string(from: self.startTime)
        return time
    }
}

/// Mediator Object for a workout required in the body of a POST request to endpoint /workout
public struct PostWorkoutMediator: Codable {
    public let appleUUID: String
    public let activityType: Int
    public let startDate: String
    public let endDate: String
    public let duration: PostUnitObject
    public let totalDistance: PostUnitObject
    public let totalCalories: PostUnitObject
    public let sourceRevision: String
    
    public var workoutEvents: [PostEvent]
    public var heartRateSamples: [PostHeartRateSample]
    public var locations: [PostWorkoutRouteSample]
    public var distanceWalkingRunningSamples: [PostDistanceWalkingRunningSample]
    
    public init(
        appleUUID: String,
        activityType: Int,
        startDate: String,
        endDate: String,
        duration: PostUnitObject,
        totalDistance: PostUnitObject,
        totalCalories: PostUnitObject,
        sourceRevision: String,
        workoutEvents: [PostEvent],
        heartRateSamples: [PostHeartRateSample],
        locations: [PostWorkoutRouteSample],
        distanceWalkingRunningSamples: [PostDistanceWalkingRunningSample]
    ) {
        self.appleUUID = appleUUID
        self.activityType = activityType
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.totalDistance = totalDistance
        self.totalCalories = totalCalories
        self.sourceRevision = sourceRevision
        self.workoutEvents = workoutEvents
        self.heartRateSamples = heartRateSamples
        self.locations = locations
        self.distanceWalkingRunningSamples = distanceWalkingRunningSamples
    }
}
