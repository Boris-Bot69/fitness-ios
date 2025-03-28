//
//  WorkoutService.swift
//  tumsm
//
//  Created by Christopher Schütz on 07.05.21.
//

import Foundation
import Combine
import HealthKit
import Shared
import CoreLocation

/// A collection of HealthKit properties, functions and utilities for retrieving workout related Health Data.
public enum HKWorkoutService {
    /// sortDescriptor for use in HKQueries
    private static let sortByDate = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
    
    static func distanceType(_ workout: HKWorkout) -> HKQuantityType? {
        switch workout.workoutActivityType {
        case .cycling:
            return HKObjectType.quantityType(forIdentifier: .distanceCycling)
        case .swimming:
            return HKObjectType.quantityType(forIdentifier: .distanceSwimming)
        default:
            return HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
        }
    }
    
    /// Fetches all workouts found for the selected date range in a synchronous manner, i.e. will block until workouts are retrieved
    static func fetchAllWorkoutsForDateRange(
        start startDate: Date,
        end endDate: Date,
        completion: @escaping ([HKWorkout]) -> Void
    ) {
        // necessary to wait for the results of HKQuery
        let dispatchGroup = DispatchGroup()
        
        var response: [HKWorkout] = []
        
        let workoutDayPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: workoutDayPredicate,
            limit: 0, // no limit
            sortDescriptors: [sortByDate]
        ) { _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                print("HealthService error \(String(describing: error))")
                return
            }
            
            response = workouts
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        HealthKitManager.healthStore.execute(query)
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(response)
        }
    }
    
    /// Fetches the distanceWalkingRunningSamples (i.e. distance covered) during the time frame of the workout in an asynchronous manner.
    static func fetchDistanceWalkingRunningSamples(_ workout: HKWorkout, completion: @escaping ([PostDistanceWalkingRunningSample]) -> Void) {
        print("********** Start Distance Walking Running Fetch")
        guard let distanceWalkingRunningType = distanceType(workout) else {
            return
        }
        
        let timeIntervalPredicate = HKSampleQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: [])
        
        let query = HKSampleQuery(
            sampleType: distanceWalkingRunningType,
            predicate: timeIntervalPredicate,
            limit: 0,
            sortDescriptors: [self.sortByDate]
        ) { _, results, error -> Void in
            // Process the detailed samples...
            guard let samples = results as? [HKQuantitySample], error == nil else {
                print("HealthService error \(String(describing: error))")
                return
            }
            
            var resultSamples: [PostDistanceWalkingRunningSample] = []
            samples.forEach { sample in
                let postSample = PostDistanceWalkingRunningSample(
                    startTime: sample.startDate.getApiFormat(),
                    endTime: sample.endDate.getApiFormat(),
                    quantity: PostDistanceWalkingRunningQuantity(
                        doubleValue: sample.quantity.doubleValue(for: .init(from: "m")),
                        unit: "m"
                    ),
                    count: sample.count,
                    device: String(describing: sample.device)
                )
                
                resultSamples.append(postSample)
            }
            
            print("********** Finish distance walking running fetch")
            completion(resultSamples)
        }
        
        HealthKitManager.healthStore.execute(query)
    }
    
    /// Fetches the heart rate samples during the time frame of the workout in an asynchronous manner.
    static func fetchHeartRateSamples(_ workout: HKWorkout, completion: @escaping ([PostHeartRateSample]) -> Void) {
        print("********** Start heart rate fetch")
        // research if we could use HKSampleQuery.predicateForObjects(from: HKWorkout) or not bc it's not directly tied to the workout?
        let workoutTimePredicate = HKSampleQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: [])
        
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: workoutTimePredicate,
            limit: 0,
            sortDescriptors: [sortByDate]
        ) { _, result, error in
            guard let samples = result as? [HKQuantitySample], error == nil else {
                print("HealthService error \(String(describing: error))")
                return
            }
            
            var resultSamples: [PostHeartRateSample] = []
            samples.forEach { sample in
                let postSample = PostHeartRateSample(
                    startTime: sample.startDate.getApiFormat(),
                    endTime: sample.endDate.getApiFormat(),
                    quantity: PostHeartRateQuantity(
                        doubleValue: sample.quantity.doubleValue(for: .init(from: "count/min")),
                        unit: "count/min"
                    ),
                    count: sample.count,
                    device: String(describing: sample.device)
                )
                resultSamples.append(postSample)
            }
            
            print("********** Finished heart rate fetch")
            completion(resultSamples)
        }
        
        HealthKitManager.healthStore.execute(query)
    }
    
//    func fetchWorkoutRoute(_ workout: HKWorkout, completion: @escaping ([HKWorkoutRoute]) -> Void) {
//        // https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings/reading_route_data
//        let runningObjectQuery = HKQuery.predicateForObjects(from: workout)
//
//        let routeQuery = HKAnchoredObjectQuery(
//            type: HKSeriesType.workoutRoute(),
//            predicate: runningObjectQuery,
//            anchor: nil,
//            limit: HKObjectQueryNoLimit
//        ) { _, samples, _, _, error in
//            guard let samples = samples as? [HKWorkoutRoute], error == nil else {
//                fatalError("The initial query failed.")
//            }
//
//            completion(samples)
//        }
//
//        HealthKitManager.healthStore.execute(routeQuery)
//    }
    
//    func fetchRouteSampleLocationData(_ route: HKWorkoutRoute, completion: @escaping ([CLLocation]) -> Void) {
//        let query = HKWorkoutRouteQuery(route: route) { _, locationsOrNil, done, errorOrNil in
//            guard let locations = locationsOrNil, errorOrNil == nil else {
//                fatalError("*** Invalid State: This can only fail if there was an error. ***")
//            }
//
////            DispatchQueue.main.async {
////                workoutModel.addLocations(locations)
////            }
//
//            if done {
//                // The query returned all the location data associated with the route.
//                // Do something with the complete data set.
//                DispatchQueue.main.async {
//                    workoutModel.locationDataLoaded = true
//                }
//            }
//        }
//
//        HealthKitManager.healthStore.execute(query)
//    }
}
