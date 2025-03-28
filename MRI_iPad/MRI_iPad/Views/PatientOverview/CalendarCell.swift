//
//  CalendarCell.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 29.05.21.
//

import SwiftUI
import Shared
import Foundation
import FontAwesomeSwiftUI

/// Each day on a calendar-sheet is represented by a CalendarCell
/// Also the CalendarCell shows activities and steps of a day
struct CalendarCell: View {
    @EnvironmentObject var model: Model
    
    var calendar: CalendarModel
    
    var date: Date
    var steps: Int? {
        guard let workoutsOverview = model.patientWorkoutsOverview else {
            return nil
        }
        return workoutsOverview.steps.first(where: { getStepMediator in
            Calendar.current.isDate(getStepMediator.date, inSameDayAs: date)
        })?.amount
    }
    
    init(date: Date, calendar: CalendarModel) {
        self.date = date
        self.calendar = calendar
    }

    var day: Int {
        Calendar.current.dateComponents([.day], from: date).day ?? 0
    }
    
    var workouts: [WorkoutsOverviewWorkoutMediator] {
        guard let workoutOverview = model.patientWorkoutsOverview else {
            return []
        }
        return workoutOverview.workouts.filter { workout in
            Calendar.current.isDate(workout.startTime, inSameDayAs: date)
        }
    }
    
    var plannedWorkouts: [PlannedWorkout] {
        guard let plannedWorkouts = model.patientWorkoutsOverview?.plannedWorkouts else {
            return []
        }
        return plannedWorkouts.filter { plannedWorkout in
            Calendar.current.isDate(plannedWorkout.plannedDate, inSameDayAs: date)
        }
    }
    
    let runningIdentifier = 37
    var runningWorkouts: [WorkoutsOverviewWorkoutMediator] { workouts.filter { $0.type == runningIdentifier } }
    var numberOfPlannedRunningWorkouts: Int { plannedWorkouts.filter { $0.type == runningIdentifier }.count }
    var numberOfMissedRunningWorkouts: Int {
        let plannedActualWorkoutsDifference =
            plannedWorkouts.filter { $0.type == runningIdentifier }.count
            - workouts.filter { $0.type == runningIdentifier }.count
        return plannedActualWorkoutsDifference > 0 ? plannedActualWorkoutsDifference : 0
    }
    
    let cyclingIdentifier = 13
    var cyclingWorkouts: [WorkoutsOverviewWorkoutMediator] { workouts.filter { $0.type == cyclingIdentifier } }
    var numberOfPlannedCyclingWorkouts: Int { plannedWorkouts.filter { $0.type == cyclingIdentifier }.count }
    var numberOfMissedCyclingWorkouts: Int {
        let plannedActualWorkoutsDifference = numberOfPlannedCyclingWorkouts - cyclingWorkouts.count
        return plannedActualWorkoutsDifference > 0 ? plannedActualWorkoutsDifference : 0
    }
    
    var otherWorkouts: [WorkoutsOverviewWorkoutMediator] { workouts.filter { $0.type != runningIdentifier && $0.type != cyclingIdentifier } }
    
    var completedWorkouts: some View {
        VStack {
            //Shows workouts that have been done 
            //Running workouts
            ForEach(0..<runningWorkouts.count) { index in
                NavigationLink(
                    destination: WorkoutOverview(workoutId: runningWorkouts[index].workoutId)) {
                    ActivityBox(
                        activityBoxType: .completedWorkout,
                        completedWorkout: runningWorkouts[index],
                        workoutWasPlanned: numberOfPlannedRunningWorkouts <= index ? false : true
                    )
                        .padding(1)
                }
            }
            //Cycling workouts
            ForEach(0..<cyclingWorkouts.count) { index in
                NavigationLink(
                    destination: WorkoutOverview(workoutId: cyclingWorkouts[index].workoutId)) {
                    ActivityBox(
                        activityBoxType: .completedWorkout,
                        completedWorkout: cyclingWorkouts[index],
                        workoutWasPlanned: numberOfPlannedCyclingWorkouts <= index ? false : true
                    )
                        .padding(1)
                }
            }
            //Other workouts
            ForEach(otherWorkouts) { workout in
                NavigationLink(
                    destination: WorkoutOverview(workoutId: workout.workoutId)) {
                    ActivityBox(activityBoxType: .completedWorkout, completedWorkout: workout)
                        .padding(1)
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    dayIndicator
                    Spacer(minLength: 0)
                    if geometry.size.width > 100 {
                        stepsView(geometry.size.width)
                    }
                }.padding(5)

                ScrollView(.vertical) {
                    VStack(alignment: .trailing, spacing: 2) {
                        completedWorkouts
                        
                        //Show missed workouts as placeholders
                        if date <= Date() {
                            if numberOfMissedRunningWorkouts > 0 {
                                ForEach((1...numberOfMissedRunningWorkouts), id: \.self) { _ in
                                    ActivityBox(activityBoxType: .placeholder, placeholderWorkoutType: 37)
                                }
                            }
                            if numberOfMissedCyclingWorkouts > 0 {
                                ForEach((1...numberOfMissedCyclingWorkouts), id: \.self) { _ in
                                    ActivityBox(activityBoxType: .placeholder, placeholderWorkoutType: 13)
                                }
                            }
                        }
                        //Show planned workouts
                        if date > Date() && !plannedWorkouts.isEmpty {
                            ForEach((plannedWorkouts), id: \.self) { plannedWorkout in
                                ActivityBox(activityBoxType: .plannedWorkout, plannedWorkout: plannedWorkout)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 2)
            .background(self.backgroundColor())
        }
    }

    func stepsView(_ width: CGFloat) -> some View {
        HStack {
            if self.date < Calendar.current.startOfDay(for: Date()) && steps != nil {
                Text(AwesomeIcon.shoePrints.rawValue).font(.awesome(style: .solid, size: 14))
                    .rotationEffect(Angle(degrees: -90.0))
                if width > 140 {
                    // careful: required like this, so that Text
                    // adds localized separator for steps > 1.000
                    // 12,345 (en), 12.345 (de) vs. 12345
                    Text("\(steps ?? 0)")
                        .fontWeight(.semibold)
                        .font(.subheadline)
                } else {
                    Text(String(format: "%dk", (steps ?? 0) / 1000))
                        .fontWeight(.semibold)
                        .font(.subheadline)
                }
            }
        }
    }

    var dayIndicator: some View {
        Text(String(format: "%2d", day))
            .foregroundColor(foregroundColor())
            .font(.headline)
            .padding(4)
            .frame(width: 30, alignment: .bottomTrailing)
    }

    func backgroundColor() -> Color {
        if isToday {
            return .BackgroundGrey
        } else {
            return .White
        }
    }

    func foregroundColor() -> Color {
        if notInCurrentMonth {
            return .FontLight
        } else {
            return .FontPrimary
        }
    }

    var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }

    var notInCurrentMonth: Bool {
         calendar.currentMonth.firstDayOfTheMonth > date || date > calendar.currentMonth.lastDayOfTheMonth
    }
}


struct CalendarCell_Previews: PreviewProvider {
    static func mockModel() -> Model {
        let model = MockModel()
        model.loadPatientsSummaries()
        model.loadPatientWorkoutsOverview(0)
        return model
    }
    
    static var previews: some View {
        LazyHGrid(
            rows: [
                .init(.fixed(20)),
                .init(.fixed(160))
            ],
            alignment: .center,
            spacing: 0
        ) {
            Group {
                Text("Not this Month")
                CalendarCell(date: Date("2021-06-29"), calendar: CalendarModel())
                    .frame(width: 160)
                    .border(Color.LightGrey)
                Text("Day before Yesterday")
                CalendarCell(date: Date().advanced(by: TimeInterval(-60 * 60 * 24 * 2)), calendar: CalendarModel())
                    .frame(width: 160)
                    .border(Color.LightGrey)
                Text("Yesterday")
                CalendarCell(date: Date().yesterday, calendar: CalendarModel())
                    .frame(width: 160)
                    .border(Color.LightGrey)
                Text("Today")
                CalendarCell(date: Date(), calendar: CalendarModel())
                    .frame(width: 160)
                    .border(Color.LightGrey)
                Text("Tomorrow")
                CalendarCell(date: Date().advanced(by: TimeInterval(60 * 60 * 24)), calendar: CalendarModel())
                    .frame(width: 160)
                    .border(Color.LightGrey)
            }
            Text("Narrow")
            CalendarCell(date: Date("2021-06-01"), calendar: CalendarModel())
                .frame(width: 100)
                .border(Color.LightGrey)
            Text("Wide")
            CalendarCell(date: Date("2021-06-01"), calendar: CalendarModel())
                .frame(width: 250)
                .border(Color.LightGrey)
        }
        .environmentObject(CalendarCell_Previews.mockModel() as Model)
        .previewLayout(.fixed(width: 1200, height: 400))
    }
}
