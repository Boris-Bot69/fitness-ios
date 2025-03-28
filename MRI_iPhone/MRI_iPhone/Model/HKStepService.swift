//
//  HKStepService.swift
//  tumsm
//
//  Created by Christopher Schütz on 13.07.21.
//

import Shared
import Combine
import HealthKit
import Foundation

struct HKStepsOfDayMediator {
    let date: Date
    let amount: Double
}

enum HKStepService {
    /// Returns all step counts for specified date range exclusive today if today is included in date range
    static func getAllStepsForDateRange(
        start: Date,
        end: Date,
        completion: @escaping ([HKStepsOfDayMediator]) -> Void
    ) {
        let datesToCalculate: [Date] = HKStepService.getAllDaysInDateRange(start: start, end: end)
        
        var result: [HKStepsOfDayMediator] = []
        
        if datesToCalculate.isEmpty {
            completion(result)
        }
        
        let dispatchGroup = DispatchGroup()
        
        datesToCalculate.forEach { day in
            dispatchGroup.enter()
            HKStepService.getStepsOfDay(day: day) { stepsAmount in
                if stepsAmount >= 0.0 {
                    result.append(HKStepsOfDayMediator(date: day, amount: stepsAmount))
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(result)
        }
    }
    
    /// Returns step count for single day in completion, otherwise 0.0
    static func getStepsOfDay(
        day: Date,
        completion: @escaping (Double) -> Void
    ) {
        guard let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: day)
        let endOfDay = startOfDay.getEndOfDay()
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            // strictStartDate: The sample’s start time must fall within the target time period.
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(-1.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        HealthKitManager.healthStore.execute(query)
    }
}

extension HKStepService {
    /// Get date objects for every day between start date and yesterday or endDate if it is smaller than yesterday.
    /// Today's date is not returned because the steps of today are not completed yet
    static func getAllDaysInDateRange(
        start: Date,
        end: Date
    ) -> [Date] {
        var result: [Date] = []
        var date = start
        
        // Explanation for use of generalTimeZone:
        // When using the regular Calendar.current (without a timezone update)
        // adding one day to the current day led to only adding 23 hours when switching
        // from winter time to summer time.
        // By now using the general GMT TimeZone adding one day leads to always precisely having
        // the next day.
        guard let generalTimeZone = TimeZone(secondsFromGMT: 0) else {
            return []
        }
        
        var generalCalendar = Calendar(identifier: .gregorian)
        generalCalendar.timeZone = generalTimeZone

        while date <= end && date < generalCalendar.startOfDay(for: Date()) {
            result.append(date)
            
            guard let nextDate = generalCalendar.date(byAdding: .day, value: 1, to: date) else {
                break
            }
            
            date = nextDate
        }
        
        return result
    }
}
