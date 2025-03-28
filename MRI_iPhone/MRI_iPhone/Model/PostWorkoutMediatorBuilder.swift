//
//  PostWorkoutMediatorBuilder.swift
//  tumsm
//
//  Created by Christopher Schütz on 13.06.21.
//

import Shared
import HealthKit
import Foundation

/// specifies build mediator function to build a postapiworkoutmediator object for a request to the api
protocol PostWorkoutMediatorBuilder {
    static func buildMediatorFromHKWorkout(
        _ hkWorkout: HKWorkout,
        completion: @escaping (PostWorkoutMediator) -> Void
    )
}

/// top level postapiworkoutmediator builder that differentiates between cardio and generic workouts
struct WorkoutBuilder: PostWorkoutMediatorBuilder {
    static func buildMediatorFromHKWorkout(
        _ hkWorkout: HKWorkout,
        completion: @escaping (PostWorkoutMediator) -> Void
    ) {
        switch hkWorkout.workoutActivityType {
        case .running, .cycling, .walking:
            RunningOrCyclingOrWalkingWorkoutBuilder.buildMediatorFromHKWorkout(
                hkWorkout,
                completion: completion
            )
        default:
            GenericWorkoutBuilder.buildMediatorFromHKWorkout(
                hkWorkout,
                completion: completion
            )
        }
    }
}

/// generic postapiworkoutmediator builder with standard functionality that does not retrieve distance and location samples
struct GenericWorkoutBuilder: PostWorkoutMediatorBuilder {
    /// converts HKWorkoutActivityType int to according string
    private static func getHKWorkoutEventTypeName(_ num: Int) -> String {
        switch num {
        case 1:
            return "pause"
        case 2:
            return "resume"
        case 3:
            return "lap"
        case 4:
            return "marker"
        case 5:
            return "motionPaused"
        case 6:
            return "motionResumed"
        case 7:
            return "segment"
        case 8:
            return "pauseOrResumeRequest"
        default:
            return "noType"
        }
    }
    
    /// converts base HKWorkoutEvents to mediator postEvents required by the api
    static func parseWorkoutEvents(_ hkWorkout: HKWorkout) -> [PostEvent] {
        var result: [PostEvent] = []
        
        guard let hkWorkoutEvents = hkWorkout.workoutEvents else {
            return result
        }
        
        hkWorkoutEvents.forEach { event in
            let postEvent = PostEvent(
                start: event.dateInterval.start.getApiFormat(),
                end: event.dateInterval.end.getApiFormat(),
                duration: event.dateInterval.duration,
                type: getHKWorkoutEventTypeName(event.type.rawValue)
            )
            result.append(postEvent)
        }
        
        return result
    }
    
    static func buildMediatorFromHKWorkout(
        _ hkWorkout: HKWorkout,
        completion: @escaping (PostWorkoutMediator) -> Void
    ) {
        let dispatchGroup = DispatchGroup()
        
        // every workout can have heart rate samples
        var tmpHeartRateSamples: [PostHeartRateSample] = []
        dispatchGroup.enter()
        HKWorkoutService.fetchHeartRateSamples(hkWorkout) { samples in
            tmpHeartRateSamples = samples
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        
        let events = parseWorkoutEvents(hkWorkout)
        
        let totalDistance = hkWorkout.totalDistance?.doubleValue(for: .init(from: "m"))
        let totalCalories = hkWorkout.totalEnergyBurned?.doubleValue(for: .init(from: "kcal"))
        
        let response = PostWorkoutMediator(
            appleUUID: hkWorkout.uuid.uuidString,
            activityType: Int(hkWorkout.workoutActivityType.rawValue),
            startDate: hkWorkout.startDate.getApiFormat(),
            endDate: hkWorkout.endDate.getApiFormat(),
            duration: PostUnitObject(doubleValue: hkWorkout.duration, unit: "s"),
            totalDistance: PostUnitObject(doubleValue: totalDistance ?? -1.0, unit: "m"),
            totalCalories: PostUnitObject(doubleValue: totalCalories ?? -1.0, unit: "kcal"),
            sourceRevision: String(describing: hkWorkout.sourceRevision),
            workoutEvents: events,
            heartRateSamples: tmpHeartRateSamples,
            // for generic workouts we do not need location or distanceWalkingRunning data
            locations: [], // replace by nil after api refactor
            distanceWalkingRunningSamples: [] // replace by nil after api refactor
        )
        
        completion(response)
    }
}

/// adds distance and location samples to postworkoutmediator object built by generic workout builder
struct RunningOrCyclingOrWalkingWorkoutBuilder: PostWorkoutMediatorBuilder {
    static func buildMediatorFromHKWorkout(
        _ hkWorkout: HKWorkout,
        completion: @escaping (PostWorkoutMediator) -> Void
    ) {
        var basicPostApiWorkoutMediator: PostWorkoutMediator?
        
        let groupOne = DispatchGroup()
        groupOne.enter()
        GenericWorkoutBuilder.buildMediatorFromHKWorkout(hkWorkout) { basicMediator in
            basicPostApiWorkoutMediator = basicMediator
            groupOne.leave()
        }
        groupOne.wait()
        
        guard var basicPostApiWorkoutMediator = basicPostApiWorkoutMediator else {
            fatalError("Could not build basic post api workout mediator")
        }
        
        let dispatchGroup = DispatchGroup()
        
        var tmpDistanceWalkingRunningSamples: [PostDistanceWalkingRunningSample] = []
        dispatchGroup.enter()
        HKWorkoutService.fetchDistanceWalkingRunningSamples(hkWorkout) { samples in
            tmpDistanceWalkingRunningSamples = samples
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        
        basicPostApiWorkoutMediator.distanceWalkingRunningSamples = tmpDistanceWalkingRunningSamples
        
        completion(basicPostApiWorkoutMediator)
    }
}
