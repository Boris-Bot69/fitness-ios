//
//  ActivityOverview.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 14.05.21.
//

import SwiftUI
import HealthKit
import FontAwesomeSwiftUI
import Shared


struct ActivityOverviewBox: View {
    @EnvironmentObject var model: Model
    
    let type: HKWorkoutActivityType
    let overview: ActivityOverview
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                Spacer()
                Text(WorkoutUtils.activityIcon(type)).font(.awesome(style: .solid, size: 32))
            }
            .frame(height: 60)
            .frame(width: 50)
            .padding(.top, 15)
            StackView(label: "Training quota".localized) {
                TrainingsRateGraph(workoutsPlanned: overview.trainingsDone, workoutsRecorded: overview.trainingsDue)
                .padding(.top, 5)
            }
            StackView(label: "Duration".localized) {
                AOText("\(WorkoutUtils.formatDuration(time: overview.duration))")
            }.frame(width: 120, alignment: .leading)
            StackView(label: "Distance".localized) {
                AOText("\(WorkoutUtils.formatDistance(distance: overview.distance))")
                    .frame(minWidth: 90, alignment: .leading)
            }
            .frame(minWidth: 120)
            StackView(label: "Heart rate".localized) {
                RangeGraph(zoneValues: overview.heartRateTrainingZones.zoneValues, showPercentagesAsText: true)
                    .frame(height: 38, alignment: .leading)
                    .padding(.top, 5)
            }
            Spacer()
        }
        .frame(height: 80)
    }
}

// A View for the activity-label
struct AOText: View {
    let label: String
    init(_ label: String) {
        self.label = label
    }

    var body: some View {
        Text(label)
            .padding(.top, 15)
            .font(.system(size: 18))
    }
}

// swiftlint:disable force_cast
struct ActivityOverview_Previews: PreviewProvider {
    static func getActivityOverview(_ overviewType: String = "running") -> ActivityOverview {
        let mockModel = MockModel()
        mockModel.loadPatientsSummaries()
        mockModel.loadPatientWorkoutsOverview(0)
        if overviewType == "cycling" {
            // don't trust the compiler! The suggested fix (replacing force cast with simple
            // forced unwrapping) doesn't work (Xcode 12.5.1)
            return mockModel.patientWorkoutsOverview?.cyclingOverview as! ActivityOverview
        } else {
            return mockModel.patientWorkoutsOverview?.runningOverview as! ActivityOverview
        }
    }

    static var previews: some View {
        VStack {
            ActivityOverviewBox(type: .running, overview: getActivityOverview("running"))
            ActivityOverviewBox(type: .cycling, overview: getActivityOverview("cycling"))
            HStack {
                Rectangle()
                ActivityOverviewBox(type: .cycling, overview: getActivityOverview("cycling"))
            }
            Spacer()
        }.padding()
    }
}
