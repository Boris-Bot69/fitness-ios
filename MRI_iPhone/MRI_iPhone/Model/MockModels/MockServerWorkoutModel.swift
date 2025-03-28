//
//  MockServerWorkoutModel.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 02.06.21.
//

import Foundation
import Shared
import HealthKit

class MockServerWorkoutModel: ServerWorkoutModel {
    override init() {
        super.init()
        self.workouts = [
            mockRunningWorkout,
            mockCyclingWorkout,
            mockStrengthWorkout,
            mockSkatingWorkout,
            mockLongStrengthWorkout,
            mockLongCyclingWorkout,
            mockLongHikingWorkout
        ]
    }
    
    override func fetchData(queryHealthKitAndUpload: Bool = false, fetchStartDate: Date, fetchEndDate: Date) {
        self.serverFetchLoadingState = .loading
        self.workouts = [
            mockRunningWorkout,
            mockCyclingWorkout,
            mockStrengthWorkout,
            mockSkatingWorkout
        ]
        self.serverFetchLoadingState = .success
    }

    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return dateFormatter
    }

    var mockRunningWorkout = WorkoutsOverviewWorkoutMediator(
        workoutId: 1,
        appleUUID: "12345",
        duration: 1747,
        startTime: dateFormatter.date(from: "2021-05-18 15:43:11+0000") ?? Date(),
        type: Int(HKWorkoutActivityType.running.rawValue),
        mainHeartRateSegment: 2,
        rating: 2,
        comment: "Great run!",
        intensity: 12.0,
        distance: 7289.0,
        calories: 565.0
    )

    var mockCyclingWorkout = WorkoutsOverviewWorkoutMediator(
        workoutId: 2,
        appleUUID: "12346",
        duration: 14723,
        startTime: dateFormatter.date(from: "2021-05-20 09:20:11+0000") ?? Date(),
        type: Int(HKWorkoutActivityType.cycling.rawValue),
        mainHeartRateSegment: 2,
        rating: 1,
        comment: "Lots of cars on the road!",
        intensity: 14.0,
        distance: 42479.0,
        calories: 1444.0
    )

    var mockStrengthWorkout = WorkoutsOverviewWorkoutMediator(
        workoutId: 3,
        appleUUID: "12347",
        duration: 14723,
        startTime: dateFormatter.date(from: "2021-05-21 19:30:04+0000") ?? Date(),
        type: Int(HKWorkoutActivityType.traditionalStrengthTraining.rawValue),
        mainHeartRateSegment: 2,
        rating: 3,
        comment: "No Pain, No Gain!",
        intensity: 18.0,
        distance: 0,
        calories: 912.0
    )

    var mockSkatingWorkout = WorkoutsOverviewWorkoutMediator(
        workoutId: 4,
        appleUUID: "12348",
        duration: 1524,
        startTime: dateFormatter.date(from: "2021-05-21 20:50:04+0000") ?? Date(),
        type: Int(HKWorkoutActivityType.skatingSports.rawValue),
        mainHeartRateSegment: 2,
        rating: 3,
        comment: "I love my new skates!",
        intensity: 7.0,
        distance: 0,
        calories: 912.0
    )

    var mockLongStrengthWorkout = WorkoutsOverviewWorkoutMediator(
        workoutId: 5,
        appleUUID: "12349",
        duration: 14723,
        startTime: dateFormatter.date(from: "2021-05-23 19:30:04+0000") ?? Date(),
        type: Int(HKWorkoutActivityType.traditionalStrengthTraining.rawValue),
        mainHeartRateSegment: 3,
        rating: 3,
        comment: "No Pain, No Gain!",
        intensity: 18.0,
        distance: 0,
        calories: 1444.0
    )

    var mockLongCyclingWorkout = WorkoutsOverviewWorkoutMediator(
        workoutId: 6,
        appleUUID: "12350",
        duration: 28723,
        startTime: dateFormatter.date(from: "2021-05-24 09:20:11+0000") ?? Date(),
        type: Int(HKWorkoutActivityType.cycling.rawValue),
        mainHeartRateSegment: 3,
        rating: 1,
        comment: "Couldn't find my way home, so I just kept on cycling!",
        intensity: 15.0,
        distance: 145584.0,
        calories: 3244.0
    )

    var mockLongHikingWorkout = WorkoutsOverviewWorkoutMediator(
        workoutId: 7,
        appleUUID: "12351",
        duration: 32234,
        startTime: dateFormatter.date(from: "2021-05-25 05:25:04+0000") ?? Date(),
        type: Int(HKWorkoutActivityType.hiking.rawValue),
        mainHeartRateSegment: 2,
        rating: 3,
        comment: "5 mountain summits in a single day!",
        intensity: 12.0,
        distance: 0,
        calories: 2888.0
    )
}
