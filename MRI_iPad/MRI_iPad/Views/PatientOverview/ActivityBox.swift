//
//  ActivityBox.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 15.05.21.
//

import SwiftUI
import Shared
import FontAwesomeSwiftUI
import HealthKit

///The activity box shows workouts, workout placeholders, or planned workouts in the PatientCalender.
struct ActivityBox: View {
    let activityBoxType: ActivityBoxType
    let completedWorkout: WorkoutsOverviewWorkoutMediator?
    let workoutWasPlanned: Bool
    let placeholderWorkoutType: Int?
    let plannedWorkout: PlannedWorkout?
    
    let activityIcon: String
    let ratingColor: Color
    let borderColor: Color
    let duration: Double?
    let durationFontColor: Color?
    
    init(
        activityBoxType: ActivityBoxType,
        completedWorkout: WorkoutsOverviewWorkoutMediator? = nil,
        workoutWasPlanned: Bool = false,
        placeholderWorkoutType: Int? = nil,
        plannedWorkout: PlannedWorkout? = nil
    ) {
        self.activityBoxType = activityBoxType
        self.completedWorkout = completedWorkout
        self.workoutWasPlanned = workoutWasPlanned
        self.placeholderWorkoutType = placeholderWorkoutType
        self.plannedWorkout = plannedWorkout
        
        switch activityBoxType {
        case .completedWorkout:
            self.activityIcon = completedWorkout?.activityIcon ?? AwesomeIcon.heart.rawValue //heart is default icon and stands for others
            self.ratingColor = completedWorkout?.ratingColor ?? .Grey //.Grey is color for workouts without a rating
            self.borderColor = completedWorkout?.cellColor ?? .Grey
            self.duration = completedWorkout?.duration
            self.durationFontColor = .FontPrimary
            
        case .placeholder:
            let healthKitActivityType = HKWorkoutActivityType(rawValue: UInt(placeholderWorkoutType ?? 0)) ?? HKWorkoutActivityType.other
            self.activityIcon = WorkoutUtils.activityIcon(healthKitActivityType)
            self.ratingColor = .LightGrey
            self.borderColor = .LightGrey
            self.duration = nil
            self.durationFontColor = .LightGrey
            
        case .plannedWorkout:
            self.activityIcon = plannedWorkout?.activityIcon ?? AwesomeIcon.heart.rawValue //heart is default icon and stands for others
            self.ratingColor = .Grey
            self.borderColor = .Grey
            self.duration = Double(plannedWorkout?.minDuration ?? 0)
            self.durationFontColor = .Grey
        }
    }

    var body: some View {
        HStack {
            Text(activityIcon).font(.awesome(style: .solid, size: 24))
                .foregroundColor(ratingColor)
            Spacer()
            if case ActivityBoxType.completedWorkout = activityBoxType {
                Text(WorkoutUtils.formatDuration(time: duration ?? 0))
                    .foregroundColor(durationFontColor)
                    .fontWeight(.semibold)
            }
            if case ActivityBoxType.plannedWorkout = activityBoxType {
                if duration != nil && duration != 0 {
                    Text(WorkoutUtils.formatDuration(time: (duration ?? 0) * 60))
                }
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 2)
                .foregroundColor(borderColor)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                                .fill(workoutWasPlanned ? Color.SuperLightBlue : .white)
                )
        )
        .padding(2)  //ensure stroke is visible
    }
}

enum ActivityBoxType {
    case completedWorkout
    case placeholder
    case plannedWorkout
}

//swiftlint:disable force_unwrapping
struct ActivityBox_Previews: PreviewProvider {
    static var previews: some View {
        let model = MockModel()
        model.loadPatientsSummaries()
        model.loadPatientWorkoutsOverview(0)
        return VStack(spacing: 0) {
            ForEach((model.patientWorkoutsOverview?.workouts)!) { workout in
                ActivityBox(activityBoxType: .completedWorkout, completedWorkout: workout)
                    .padding(1)
            }
            Spacer()
        }.previewLayout(PreviewLayout.fixed(width: 140, height: 200))
    }
}
