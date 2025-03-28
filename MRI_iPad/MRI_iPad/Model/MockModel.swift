//
//  MockModel.swift
//  DoctorsApp
//
//  Created by Christopher Schütz on 18.06.21.
//

import Foundation
import Shared

enum MockSteps {
    static func getSteps(_ count: Int, min: Int = 5432, max: Int = 14000) -> [Int] {
        (0..<count).map { _ in .random(in: min...max) }
    }
}

/// Provides Mock Data for testing without a connection to the api
class MockModel: Model {
    let steps = MockSteps.getSteps(12 * 31)
    
    override init() {
        super.init()
        self.patientsSummaries = patientsSummaries
        self.patientWorkoutsOverview = patientWorkoutsOverview
        self.patientDetailedWorkout = patientDetailedWorkout

        self.patientWorkoutsOverviewLoadingState = .notStarted
        self.patientDetailedWorkoutLoadingState = .notStarted
        self.patientsSummariesLoadingState = .notStarted
    }
    
    // MARK: Patients' Summaries
    override func loadPatientsSummaries() {
        self.patientsSummaries = MockModelFactory.createPatientsSummaries()
        self.patientsSummariesLoadingState = .loadedSuccessfully
    }
    
    // MARK: Patient Workouts Overview
    override func loadPatientWorkoutsOverview(_ patientId: Int, startDate: Date = .distantPast, endDate: Date = .distantFuture) {
        self.patientWorkoutsOverview = MockModelFactory.createPatientsOverviews()[0]
        self.patientWorkoutsOverviewLoadingState = .loadedSuccessfully
    }
    
    // MARK: Patient Detailed Workout
    override func loadDetailedWorkout(identifier: Int, withSampleRate sampleRate: Int = 10) {
        self.patientDetailedWorkout = MockModelFactory.createPatientDetailedWorkouts().first(where: { detailedWorkout in
            detailedWorkout.id == identifier
        })
        self.patientDetailedWorkoutLoadingState = .loadedSuccessfully
    }
}
