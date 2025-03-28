//
//  ServerWorkoutModel.swift
//  tumsm
//
//  Created by Christopher Schütz on 24.05.21.
//

import Shared
import Combine
import HealthKit
import Foundation
import FontAwesomeSwiftUI

enum LoadingState {
    case notStarted
    case loading
    case failed
    case success
}

class ServerWorkoutModel: ObservableObject {
    let workoutService = WorkoutService()
    
    @Published var serverFetchLoadingState: LoadingState = .notStarted
    @Published var serverUploadLoadingState: LoadingState = .notStarted
    
    @Published var workouts: [WorkoutsOverviewWorkoutMediator] = []
    @Published var steps: [GetStepMediator] = []
    
    @Published var numberOfItemsToUpload: Int = 0
    @Published var numberOfItemsUploaded: Int = 0
    @Published var numberOfItemsFailedToUpload: Int = 0

    func workout(_ id: Int) -> WorkoutsOverviewWorkoutMediator {
        workouts.first(where: { $0.workoutId == id }) ?? MockServerWorkoutModel().workouts[0]
    }
    
    func workout(_ appleUUID: String) -> WorkoutsOverviewWorkoutMediator? {
        workouts.first(where: { $0.appleUUID == appleUUID })
    }

    func setWorkouts(_ workouts: [WorkoutsOverviewWorkoutMediator]) {
        self.workouts = workouts.sorted().reversed()
    }
    
    func setSteps(_ steps: [GetStepMediator]) {
        self.steps = steps
    }

    func update(_ id: Int, intensity: Double, comment: String, rating: WorkoutRating) {
        let workout = workouts.first { workout in
            workout.workoutId == id
        }
        guard var workout = workout else {  /// Don't trust Xcode! Keep as `var`, `let` will cause "abort trap 6" error
            print("Error. Couldn't find workout")
            return
        }
        guard !(workout.intensity == intensity &&
                    workout.comment == comment &&
                    workout.rating == rating.value) else {
            return
        }
        workout.intensity = intensity
        workout.comment = comment
        workout.rating = rating.value
        workouts.replaceAndSort(workout)
        uploadRating(PostRatingMediator(
                        workoutId: workout.workoutId,
                        rating: workout.rating,
                        intensity: Int(workout.intensity),
                        comment: workout.comment),
                     completion: { responseOrNil in
                        guard let response = responseOrNil else {
                            print("Upload rating unsuccessful!")
                            return
                        }
                        print("Successfully uploaded rating #\(response.rating)")
                     })
    }

    /// uploads the rating object. returns true if upload was successful or false otherwise
    func uploadRating(_ rating: PostRatingMediator, completion: @escaping (PostRatingResponse?) -> Void) {
        workoutService.postRating(rating)
            .sink(
                receiveCompletion: { completion in
                    print(completion)
                }, receiveValue: { postRatingResponse in
                    completion(postRatingResponse)
                })
            .store(in: &cancellables)
    }
    
    private var cancellables: [AnyCancellable] = []
}

extension ServerWorkoutModel {
    @objc
    func fetchData(queryHealthKitAndUpload: Bool = false, fetchStartDate: Date, fetchEndDate: Date) {
        self.serverFetchLoadingState = .loading
        workoutService.getWorkoutsOverview(start: fetchStartDate, end: fetchEndDate)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Retrieved workout/overviews successfully")
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.serverFetchLoadingState = .failed
                    }
                },
                receiveValue: { workoutsOverview in
                    self.setWorkouts(workoutsOverview.workouts)
                    self.setSteps(workoutsOverview.steps)
                    self.serverFetchLoadingState = .success
                    
                    if queryHealthKitAndUpload {
                        self.retrieveHealthKitData(
                            start: fetchStartDate,
                            end: fetchEndDate
                        ) { hkWorkouts, steps in
                            var hkWorkoutsAsVar = hkWorkouts
                            var stepsAsVar = steps
                            
                            // Delta Calculation
                            let workoutsToUpload = self.getWorkoutsToUpload(&hkWorkoutsAsVar)
                            let stepsToUpload = self.getStepsToUpload(&stepsAsVar)
                            
                            self.uploadData(hkWorkouts: workoutsToUpload, steps: stepsToUpload)
                        }
                    }
                })
            .store(in: &cancellables)
    }
    
    private func getWorkoutsToUpload(_ hkWorkouts: inout [HKWorkout]) -> [HKWorkout] {
        hkWorkouts.removeAll(where: { hkWorkout in
            self.workouts.map { serverWorkout in
                serverWorkout.appleUUID
            }
            .contains(hkWorkout.uuid.uuidString)
        })
        return hkWorkouts
    }
    
    private func getStepsToUpload(_ steps: inout [HKStepsOfDayMediator]) -> [HKStepsOfDayMediator] {
        steps.removeAll(where: { stepOfDayContainer in
            self.steps.map { getStepMediator in
                Calendar.current.isDate(stepOfDayContainer.date, inSameDayAs: getStepMediator.date)
            }
            .contains(true)
        })
        return steps
    }
    
    private func uploadData(hkWorkouts: [HKWorkout], steps: [HKStepsOfDayMediator]) {
        self.numberOfItemsToUpload = hkWorkouts.count + steps.count
        self.numberOfItemsUploaded = 0
        self.numberOfItemsFailedToUpload = 0
        
        if self.numberOfItemsToUpload == 0 {
            // No Data To Upload
            print("No new data uploading")
            self.serverUploadLoadingState = .success
            return
        }
        
        self.serverUploadLoadingState = .loading
        
        let uploadDispatchGroup = DispatchGroup()
        uploadDispatchGroup.enter()
        uploadDispatchGroup.enter()
        
        // upload workouts
        uploadRemainingWorkouts(workoutsToUpload: hkWorkouts) {
            uploadDispatchGroup.leave()
        }
        
        // upload steps
        uploadRemainingSteps(stepsToUpload: steps) {
            uploadDispatchGroup.leave()
        }
        
        uploadDispatchGroup.notify(queue: DispatchQueue.main) {
            self.serverUploadLoadingState = .success
        }
    }
    
    private func retrieveHealthKitData(
        start: Date,
        end: Date,
        completion: @escaping ([HKWorkout], [HKStepsOfDayMediator]) -> Void
    ) {
        guard self.serverFetchLoadingState == .success else {
            print("Will not query HealthKit before successful Server Fetch")
            return
        }
        
        let healthKitDispatchGroup = DispatchGroup()
        
        // two jobs to be done: fetch workouts and fetch steps
        healthKitDispatchGroup.enter()
        healthKitDispatchGroup.enter()
        
        var healthKitWorkouts: [HKWorkout] = []
        HKWorkoutService.fetchAllWorkoutsForDateRange(start: start, end: end) { workouts in
            healthKitWorkouts = workouts
            healthKitDispatchGroup.leave()
        }
        
        var healthKitSteps: [HKStepsOfDayMediator] = []
        HKStepService.getAllStepsForDateRange(
            start: start,
            end: end
        ) { steps in
            healthKitSteps = steps
            healthKitDispatchGroup.leave()
        }
        
        healthKitDispatchGroup.notify(queue: DispatchQueue.main) {
            completion(healthKitWorkouts, healthKitSteps)
        }
    }
    
    func uploadRemainingWorkouts(workoutsToUpload workouts: [HKWorkout], completion: (() -> Void)? = nil) {
        DispatchQueue.background(
            background: {
                workouts.forEach { hkWorkout in
                    WorkoutBuilder.buildMediatorFromHKWorkout(hkWorkout) { postWorkoutMediator in
                        self.workoutService.postWorkout(postWorkoutMediator)
                            .receive(on: RunLoop.main)
                            .sink(
                                receiveCompletion: { completion in
                                    if case .failure = completion {
                                        self.numberOfItemsFailedToUpload += 1
                                    }
                                },
                                receiveValue: { _ in
                                    self.numberOfItemsUploaded += 1
                                })
                            .store(in: &self.cancellables)
                    }
                }
            },
            completion: completion
        )
    }
    
    func uploadRemainingSteps(stepsToUpload steps: [HKStepsOfDayMediator], completion: (() -> Void)? = nil) {
        DispatchQueue.background(
            background: {
                steps.forEach { stepOfDayContainer in
                    let postStepMediator = PostStepMediator(
                        date: stepOfDayContainer.date.getStepsApiFormat(),
                        amount: UInt(stepOfDayContainer.amount)
                    )
                    self.workoutService.postSteps(postStepMediator)
                        .receive(on: RunLoop.main)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure = completion {
                                    self.numberOfItemsFailedToUpload += 1
                                }
                            },
                            receiveValue: { _ in
                                self.numberOfItemsUploaded += 1
                            })
                        .store(in: &self.cancellables)
                }
            },
            completion: completion
        )
    }
}
