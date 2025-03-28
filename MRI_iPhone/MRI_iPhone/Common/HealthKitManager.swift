//
//  HealthKitManager.swift
//  tumsm
//
//  Created by Christopher Schütz on 07.05.21.
//

import Foundation
import HealthKit

/// manages access to healthkit
public enum HealthKitManager {
    /// healthstore
    public static let healthStore = HKHealthStore()
    
    static var allTypes: Set<HKObjectType> {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return Set()
        }
        
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return Set()
        }
        
        guard let distanceWalkingRunningType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return Set()
        }
        
        guard let distanceCyclingType = HKObjectType.quantityType(forIdentifier: .distanceCycling) else {
            return Set()
        }
        
        guard let distanceSwimmingType = HKObjectType.quantityType(forIdentifier: .distanceSwimming) else {
            return Set()
        }
        
        return Set([
            stepCountType,
            heartRateType,
            distanceWalkingRunningType,
            distanceCyclingType,
            distanceSwimmingType,
            HKObjectType.workoutType(),
            HKSeriesType.workoutRoute()
        ])
    }
    
    static func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        if HKHealthStore.isHealthDataAvailable() {
            HealthKitManager.healthStore.requestAuthorization(toShare: nil, read: allTypes) { authorized, error in
                if error != nil {
                    print("HealthKit Authorization Error: \(String(describing: error))")
                    return
                }
                
                completion(authorized, error)
                print("HealthKit authorization request was successful!")
            }
        }
    }
}
