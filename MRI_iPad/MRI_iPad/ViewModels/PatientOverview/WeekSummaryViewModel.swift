//
//  WeekSummaryViewModel.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 28.06.21.
//

import Foundation
import Shared

/// A model-class to work with the data from ApiModel and provide them to the view
class WeekSummaryViewModel: ObservableObject {
    var model: Model?
    
    @Published var bikeDistance: Double = 0
    @Published var bikeTime: Int = 0
    @Published var runningDistance: Double = 0
    @Published var runningTime: Int = 0
    
    var week: Date
    var sheet: [Date: [Date]]
    var weekStart: Date
    
    init(week: Date, sheet: [Date: [Date]]) {
        self.week = week
        self.sheet = sheet
        self.weekStart = sheet[week]?[0] ?? Date()
    }
    
    // Important function which sets the Model
    func setup(model: Model) {
        self.model = model
        self.loadData()
    }
    
    func loadData() {
        var idx = 0
        while idx < (sheet[week]?.count ?? 0) {
            let workoutsOfDay = self.workoutsForDayFound(for: sheet[week]?[idx] ?? Date())
            workoutsOfDay.forEach {
                // @Jannis: I will rework this part over the weekend but i didn't get it done before the code-review
                if $0.activityType == .cycling {
                    bikeDistance += $0.distance
                    bikeTime += Int($0.duration)
                }
                if $0.activityType == .running {
                    runningDistance += $0.distance
                    runningTime += Int($0.duration)
                }
            }
            idx += 1
        }
    }
    
    // Basically the same function as in the CalendarCell with small changes in used variables
    // @Christopher: should we move this function to ApiModel or a utility-class?
    func workoutsForDayFound(for date: Date) -> [WorkoutsOverviewWorkoutMediator] {
        if model?.patientWorkoutsOverview != nil {
            if let workouts = model?.patientWorkoutsOverview?.workouts {
                return workouts.filter { apiWorkout in
                    Foundation.Calendar.current.isDate(apiWorkout.startTime, inSameDayAs: date)
                }
            }
        }
        
        return []
    }
}
