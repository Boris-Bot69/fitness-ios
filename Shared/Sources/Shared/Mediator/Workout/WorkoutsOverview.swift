//
//  APIWorkoutOverviews.swift
//  
//
//  Created by Christopher Schütz on 03.06.21.
//

import Foundation

/// Mediator Object for a workouts overview in the response provided by GET on endpoint /workout/overviews
public class WorkoutsOverviewMediator: Codable {
    public let name: String
    public let studyGroup: String?
    public let treatmentGoal: String
    public let workouts: [WorkoutsOverviewWorkoutMediator]
    public let steps: [GetStepMediator]
    public let runningOverview: RunningOverview
    public let cyclingOverview: CyclingOverview
    public let plannedWorkouts: [PlannedWorkout]
    
    public init(
        name: String,
        studyGroup: String?,
        treatmentGoal: String,
        workouts: [WorkoutsOverviewWorkoutMediator],
        steps: [GetStepMediator],
        runningOverview: RunningOverview,
        cyclingOverview: CyclingOverview,
        plannedWorkouts: [PlannedWorkout] = []
    ) {
        self.name = name
        self.studyGroup = studyGroup
        self.treatmentGoal = treatmentGoal
        self.workouts = workouts
        self.runningOverview = runningOverview
        self.cyclingOverview = cyclingOverview
        self.plannedWorkouts = plannedWorkouts
        self.steps = steps
    }
}
