//
//  WorkoutInfoView.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 11.06.21.
//

import SwiftUI
import Shared

struct WorkoutInfoView: View {
    @EnvironmentObject var model: ServerWorkoutModel
    let workoutId: Int
    var workout: WorkoutsOverviewWorkoutMediator {
        model.workout(workoutId)
    }
    
    init(workoutId: Int) {
        self.workoutId = workoutId
    }

    var body: some View {
        HStack(spacing: 12) {
            activityIcon
                .foregroundColor(.IconBlue)
                .frame(width: 70, alignment: .center)
            VStack(alignment: .leading) {
                HStack {
                    Text(workout.primaryMetric.0 + workout.primaryMetric.1)
                        .font(.title)
                        .bold()
                    Text("(\(workout.secondaryMetric))")
                        .font(.title2)
                }.foregroundColor(.IconBlue)
                Text(workout.relativeDateDescription)
                    .foregroundColor(.FontLight)
            }
            Spacer()
        }
    }

    var activityIcon: Text {
        Text(workout.activityIcon)
            .font(.awesome(style: .solid, size: 55))
    }
}

struct WorkoutInfoView_Previews: PreviewProvider {
    static var model = MockServerWorkoutModel()
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            VStack {
                ForEach(model.workouts) { workout in
                    WorkoutInfoView(workoutId: workout.workoutId)
                        .padding(.top)
                }
            }
            .padding(.horizontal)
            .background(
                Color(.systemBackground)
                    .ignoresSafeArea(.all, edges: .all)
            )
            .colorScheme(colorScheme)
        }.environmentObject(model as ServerWorkoutModel)
    }
}
