//
//  Model.swift
//  DoctorsApp
//
//  Created by Christopher Schütz on 18.06.21.
//
// swiftlint:disable discouraged_optional_collection

import Foundation
import Shared

// MARK: Model
/// Encapsulates all data necessary for a doctor about patients, their monthly overviews and detailed workouts
class Model: ObservableObject {
    // MARK: Published Variables
    @Published var patientsSummariesLoadingState: LoadingState = .notStarted
    @Published var patientsSummaries: [PatientSummary]?
    
    @Published var patientWorkoutsOverviewLoadingState: LoadingState = .notStarted
    @Published var patientWorkoutsOverview: WorkoutsOverviewMediator?
    
    @Published var patientDetailedWorkoutLoadingState: LoadingState = .notStarted
    @Published var patientDetailedWorkout: GetWorkoutMediator?
    
    @Published var patientMonthlyActivityLoadingState: LoadingState = .notStarted
    @Published var patientMonthlyActivity: WorkoutsOverviewMediator?
    
    func loadPatientsSummaries() {
        // stub
    }
    
    func loadPatientWorkoutsOverview(_ patientId: Int, startDate: Date = .distantPast, endDate: Date = .distantFuture) {
        // stub
    }
    
    func loadDetailedWorkout(identifier: Int, withSampleRate sampleRate: Int = 10) {
        // stub
    }
    
    func loadMonthlyActivity(_ patientId: Int, month: Date) {
        // stub
    }
}

/// Collection of all loading states for all published variables in Model
enum LoadingState {
    case notStarted
    case loading
    case loadingFailed
    case loadedSuccessfully
}
