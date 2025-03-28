//
//  ServerModel.swift
//  DoctorsApp
//
//  Created by Christopher Schütz on 18.06.21.
//

import Shared
import Combine
import Foundation

/// Provides Model with connection to the Api
class ServerModel: Model {
    override init() {
        super.init()
        
        self.patientsSummaries = patientsSummaries
        self.patientWorkoutsOverview = patientWorkoutsOverview
        self.patientDetailedWorkout = patientDetailedWorkout

        self.patientWorkoutsOverviewLoadingState = .notStarted
        self.patientDetailedWorkoutLoadingState = .notStarted
        self.patientsSummariesLoadingState = .notStarted
    }
    
    // MARK: Api Services
    let patientService = PatientService()
    let workoutService = WorkoutService()
    
    // MARK: Patients' Summaries
    private func setPatientsSummaries(_ summaries: [PatientSummary]) {
        self.patientsSummaries = summaries
    }
    
    override func loadPatientsSummaries() {
        self.patientsSummariesLoadingState = .loading
        
        patientService.getSummariesOfPatients()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        self.patientsSummariesLoadingState = .loadingFailed
                        self.patientsSummaries = nil
                    }
                },
                receiveValue: { patientsSummaries in
                    self.setPatientsSummaries(patientsSummaries)
                    self.patientsSummariesLoadingState = .loadedSuccessfully
                })
            .store(in: &cancellables)
    }
    
    // MARK: Patient Workouts Overview
    
    // start and end range of fetched data that will be incorporated in the overview
    private var overviewFetchStartDate = Date().startOfMonth
    private var overviewFetchEndDate = Date().endOfMonth
    
    func setOverviewFetchStartDate(_ date: Date) {
        self.overviewFetchStartDate = date
    }
    
    func setOverviewFetchEndDate(_ date: Date) {
        self.overviewFetchEndDate = date
    }
    
    // Sets the fetch start and end range on the start and end date of the month
    // in which the provided date lies.
    func setFetchDatesForMonth(_ date: Date) {
        self.setOverviewFetchStartDate(date.startOfMonth)
        self.setOverviewFetchEndDate(date.endOfMonth)
    }
    
    private func setPatientWorkoutsOverview(_ overview: WorkoutsOverviewMediator) {
        self.patientWorkoutsOverview = overview
    }
    
    private func setMonthlyActivity(_ overview: WorkoutsOverviewMediator) {
        self.patientMonthlyActivity = overview
    }
    
    override func loadPatientWorkoutsOverview(_ patientId: Int, startDate: Date = .distantPast, endDate: Date = .distantFuture) {
        self.patientWorkoutsOverviewLoadingState = .loading
        
        workoutService.getWorkoutsOverview(
            start: startDate,
            end: endDate,
            patientId: patientId
        )
        .receive(on: RunLoop.main)
        .sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    self.patientWorkoutsOverviewLoadingState = .loadingFailed
                    self.patientWorkoutsOverview = nil
                }
            },
            receiveValue: { workoutsOverview in
                self.setPatientWorkoutsOverview(workoutsOverview)
                self.patientWorkoutsOverviewLoadingState = .loadedSuccessfully
            })
        .store(in: &cancellables)
    }
    
    override func loadMonthlyActivity(_ patientId: Int, month: Date) {
        self.patientWorkoutsOverviewLoadingState = .loading
        
        workoutService.getWorkoutsOverview(
            start: month.firstDayOfTheMonth,
            end: month.lastDayOfTheMonth,
            patientId: patientId
        )
        .receive(on: RunLoop.main)
        .sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    self.patientMonthlyActivityLoadingState = .loadingFailed
                    self.patientMonthlyActivity = nil
                }
            },
            receiveValue: { workoutsOverview in
                self.setMonthlyActivity(workoutsOverview)
                self.patientMonthlyActivityLoadingState = .loadedSuccessfully
            })
        .store(in: &cancellables)
    }
    
    // MARK: Patient Detailed Workout
    private func setPatientDetailedWorkout(_ workout: GetWorkoutMediator) {
        self.patientDetailedWorkout = workout
    }
    
    private var cancellables: [AnyCancellable] = []
    
    override func loadDetailedWorkout(identifier: Int, withSampleRate sampleRate: Int = 10) {
        self.patientDetailedWorkoutLoadingState = .loading
        workoutService.getWorkout(identifier: identifier, sampleRate: sampleRate)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        self.patientDetailedWorkoutLoadingState = .loadingFailed
                    }
                },
                receiveValue: { detailedWorkout in
                    self.patientDetailedWorkout = detailedWorkout
                    self.patientDetailedWorkoutLoadingState = .loadedSuccessfully
                }
            )
            .store(in: &cancellables)
    }
}
