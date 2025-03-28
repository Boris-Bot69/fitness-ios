//
//  WorkoutCell.swift
//  tumsm
//
//  Created by Christopher Schütz on 24.05.21.
//

import SwiftUI
import FontAwesomeSwiftUI
import Shared
import HealthKit

struct WorkoutCell: View {
    @EnvironmentObject var model: ServerWorkoutModel
    var id: Int
    var workout: WorkoutsOverviewWorkoutMediator {
        model.workout(id)
    }
    
    init(id: Int) {
        self.id = id
    }
    
    var body: some View {
        HStack {
            Text(workout.activityIcon)
                .font(.awesome(style: .solid, size: 48))
                .frame(width: 64)
                .foregroundColor(.IconBlue)
            VStack(alignment: .leading) {
                Text(workout.primaryMetric.0 + " " + workout.primaryMetric.1)
                    .font(.title3)
                    .bold()
                Text(workout.relativeDateDescription)
                    .font(.caption)
            }
            Spacer()
            Group {
                Text(activityLinkText)
            }.foregroundColor(.accentColor)
        }
    }

    var activityCustomIcon: Image {
        switch workout.activityType {
        case HKWorkoutActivityType.running:
            return Image("ActivityIconRunning")
        case HKWorkoutActivityType.cycling:
            return Image("ActivityIconCycling")
        default:
            return Image("ActivityIconDefault")
        }
    }

    var activityLinkText: String {
        (workout.rating == 0 || workout.rating == -1) ? "rate" : "details"
    }
}

struct WorkoutCell_Previews: PreviewProvider {
    private static let model = MockServerWorkoutModel()
    static var previews: some View {
        List {
            WorkoutCell(id: model.workouts[0].workoutId)
            WorkoutCell(id: model.workouts[1].workoutId)
            WorkoutCell(id: model.workouts[2].workoutId)
            WorkoutCell(id: model.workouts[3].workoutId)
        }
        .environmentObject(model as ServerWorkoutModel)
    }
}
