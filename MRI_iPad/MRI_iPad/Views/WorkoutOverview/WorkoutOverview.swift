//
//  WorkoutOverview.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 12.05.21.
//
// swiftlint:disable closure_body_length force_unwrapping

import SwiftUI
import FontAwesomeSwiftUI
import Shared
import HealthKit

struct WorkoutOverview: View {
    @EnvironmentObject var model: Model
    
    var workoutId: Int
    
    var chartCount: Int {
        var count = 0
        
        if let workout = model.patientDetailedWorkout {
            if let profile = workout.combinedProfiles.first {
                if profile.altitude != nil {
                    count += 1
                }
                if profile.speed != nil {
                    count += 1
                }
                if profile.heartRate != nil {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    var body: some View {
        ScrollView(.vertical) {
            switch model.patientDetailedWorkoutLoadingState {
            case .loadedSuccessfully:
                HStack {
                    VStack(alignment: .leading) {
                        topBar
                        if model.patientDetailedWorkout?.trainingZones.heartRate != nil {
                            heartRateOverview
                        }
                        if model.patientDetailedWorkout?.trainingZones.speed != nil {
                            speedOverview
                        }
                        feedbackOverview
                        // define size of UIKit component within SwiftUI
                        VStack {
                            HealthChartView(workout: model.patientDetailedWorkout!)
                        }
                        .frame(height: CGFloat(chartCount * 350))
                        .padding(.horizontal, 8)
                        WorkoutDataTable()
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 35)
                }
                .padding(.bottom, 24)
            case .loading:
                VStack {
                    Spacer()
                    Text("Workout is loading...")
                        .font(.headline)
                        .foregroundColor(.FontPrimary)
                    Spacer()
                    WorkoutDataTable()
                }
            case .loadingFailed:
                VStack {
                    Spacer()
                    Text("Loading Failed!")
                        .font(.headline)
                        .foregroundColor(.FontPrimary)
                    Spacer()
                }
            case .notStarted:
                VStack {
                    Spacer()
                    Text("Fetching has not started...")
                        .font(.headline)
                    Spacer()
                }
            }
        }
        // Handle Networking
        .onAppear(perform: {
            model.loadDetailedWorkout(identifier: workoutId)
        })
    }
    
    let iconSize: CGFloat = 22
    let leadingIconFrameSize: CGFloat = 70
    let columnSize: CGFloat = 120
    var topBar: some View {
        HStack {
            if let workout = model.patientDetailedWorkout {
                HStack {
                    Text(WorkoutUtils.activityIcon(HKWorkoutActivityType(rawValue: UInt(workout.type)) ?? .other))
                        .font(.awesome(style: .solid, size: 50))
                        .foregroundColor(.DarkBlue)
                        .frame(width: leadingIconFrameSize)
                    
                    HStack {
                        Group {
                            HStack {
                                Text(AwesomeIcon.calendar.rawValue).font(.awesome(style: .solid, size: iconSize))
                                    .foregroundColor(.DarkBlue)
                                Text(workout.startTime.asDateString)
                            }
                            .padding(.leading)
                            HStack {
                                Text(AwesomeIcon.clock.rawValue).font(.awesome(style: .solid, size: iconSize))
                                    .foregroundColor(.DarkBlue)
                                Text(workout.startTime.asTimeString)
                            }
                            HStack {
                                Text(AwesomeIcon.stopwatch.rawValue).font(.awesome(style: .solid, size: iconSize + 3))
                                    .foregroundColor(.DarkBlue)
                                Text("\(WorkoutUtils.formatDuration(time: workout.duration))")
                            }
                            HStack {
                                Text(AwesomeIcon.route.rawValue).font(.awesome(style: .solid, size: iconSize))
                                    .foregroundColor(.DarkBlue)
                                Text(String(format: "%2.1fkm", (workout.distance ?? 0) / 1000))
                            }
                            HStack {
                                Text(AwesomeIcon.fireAlt.rawValue).font(.awesome(style: .solid, size: iconSize))
                                    .foregroundColor(.DarkBlue)
                                Text("\(workout.kcal)kcal")
                            }
                            if let terrainUp = workout.terrainUp {
                                if !terrainUp.isZero {
                                    HStack {
                                        Text(AwesomeIcon.arrowUp.rawValue).font(.awesome(style: .solid, size: iconSize))
                                            .foregroundColor(.DarkBlue)
                                        Text("\(Int(terrainUp))")
                                    }
                                    .padding(.trailing, 2)
                                }
                            }
                            if let terrainDown = workout.terrainDown {
                                if !terrainDown.isZero {
                                    HStack {
                                        Text(AwesomeIcon.arrowDown.rawValue).font(.awesome(style: .solid, size: iconSize))
                                            .foregroundColor(.DarkBlue)
                                        Text("\(Int(terrainDown))")
                                    }
                                    .padding(.trailing, 10)
                                }
                            }
                        }
                        .padding(.trailing, 14)
                    }
                }
            }
        }
        .font(.headline)
    }
    
    var heartRateOverview: some View {
        HStack {
            if let workout = model.patientDetailedWorkout {
                Text(AwesomeIcon.heartbeat.rawValue).font(.awesome(style: .solid, size: 28))
                    .foregroundColor(.DarkBlue)
                    .frame(width: leadingIconFrameSize)
                Group {
                    StackView(label: "Ø") {
                        Text("\(Int(workout.heartRateAverage ?? 0.0))" + " bpm")
                    }
                    StackView(label: "min".localized) {
                        Text("\(Int(workout.heartRateMinimum ?? 0.0))" + " bpm")
                    }
                    StackView(label: "max".localized) {
                        Text("\(Int(workout.heartRateMaximum ?? 0.0))" + " bpm")
                    }
                }
                .frame(width: columnSize, alignment: .leading)
                StackView(label: "heart rate".localized) {
                    RangeGraph(zoneValues: heartRateZonesValues, showPercentagesAsText: true)
                        .frame(height: 30)
                }
            }
        }
    }
    
    var heartRateZonesValues: [Int] {
        if let workout = model.patientDetailedWorkout, let heartRate = workout.trainingZones.heartRate {
            var result: [Int] = []
            result.append(heartRate.zone0)
            result.append(heartRate.zone1)
            result.append(heartRate.zone2)
            result.append(heartRate.zone3)
            result.append(heartRate.zone4)
            return result
        } else {
            return []
        }
    }
    
    var speedOverview: some View {
        HStack {
            if let workout = model.patientDetailedWorkout {
                if (workout.speedMinimum ?? 0) > 0 {
                    Text(AwesomeIcon.stopwatch.rawValue).font(.awesome(style: .solid, size: 28))
                        .foregroundColor(.DarkBlue)
                        .frame(width: leadingIconFrameSize)
                    Group {
                        StackView(label: "Ø") {
                            Text("\(String(format: "%.1f", workout.speedAverage ?? 0.0)) km/h")
                        }
                        StackView(label: "min".localized) {
                            Text("\(String(format: "%.1f", workout.speedMinimum ?? 0.0)) km/h")
                        }
                        StackView(label: "max".localized) {
                            Text("\(String(format: "%.1f", workout.speedMaximum ?? 0.0)) km/h")
                        }
                    }
                    .frame(width: columnSize, alignment: .leading)
                    StackView(label: "speed".localized) {
                        RangeGraph(zoneValues: speedZoneValues, showPercentagesAsText: true)
                            .frame(height: 30)
                    }
                }
            }
        }
    }
    
    var speedZoneValues: [Int] {
        if let workout = model.patientDetailedWorkout, let speed = workout.trainingZones.speed {
            var result: [Int] = []
            result.append(speed.zone0)
            result.append(speed.zone1)
            result.append(speed.zone2)
            result.append(speed.zone3)
            result.append(speed.zone4)
            return result
        } else {
            return []
        }
    }
    
    var feedbackAvailable: Bool {
        if let workout = model.patientDetailedWorkout {
            if workout.rating != -1 {
                return true
            }
            if !workout.comment!.isEmpty {
                return true
            }
            if workout.intensity > 0 {
                return true
            }
        }
        return false
    }
    
    var feedbackOverview: some View {
        HStack {
            if let workout = model.patientDetailedWorkout {
                if feedbackAvailable {
                    HStack {
                        Text("") //Without this or with an EmptyView() this placeholderbox is too small
                    }.frame(width: leadingIconFrameSize, alignment: .leading)
                    Group {
                        StackView(label: "Rating".localized) {
                            switch workout.rating {
                            case 1: Text("bad".localized)
                            case 2: Text("medium".localized)
                            case 3: Text("good".localized)
                            default: Text("missing".localized)
                            }
                        }
                        StackView(label: "Intensity".localized) {
                            workout.intensity == -1
                                ? Text("missing")
                                : Text("\(workout.intensity)")
                        }
                    }
                    .frame(width: columnSize, alignment: .leading)
                    StackView(label: "Comment".localized) {
                        if let comment = workout.comment {
                            comment.isEmpty
                            ? Text("\("no comment given".localized)")
                                .fontWeight(.bold)
                            : Text(comment)
                                .fontWeight(.regular)
                        } else {
                            Text("\("no comment given".localized)")
                        }
                    }
                }
            }
        }
    }
}

struct WorkoutOverview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WorkoutOverview(workoutId: 1)
                // iPad Pro 12.9" landscape viewport
                .previewLayout(.fixed(width: 1366, height: 1024))
        }
    }
}
