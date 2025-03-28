//
//  WorkoutUtils.swift
//
//
//  Created by Jannis Mainczyk on 01.07.21.
//

import Foundation
import HealthKit
import FontAwesomeSwiftUI

/// Utilities when working with workout data
public enum WorkoutUtils {
    /// Return FontAwesome icon string based on this workout's activityType
    public static func activityIcon(_ activityType: HKWorkoutActivityType) -> String {
        switch activityType {
        case HKWorkoutActivityType.running:
            return AwesomeIcon.running.rawValue
        case HKWorkoutActivityType.cycling:
            return AwesomeIcon.biking.rawValue
        case HKWorkoutActivityType.functionalStrengthTraining,
             HKWorkoutActivityType.traditionalStrengthTraining,
             HKWorkoutActivityType.highIntensityIntervalTraining:
            return AwesomeIcon.dumbbell.rawValue
        case HKWorkoutActivityType.hiking:
            return AwesomeIcon.hiking.rawValue
        case HKWorkoutActivityType.walking:
            return AwesomeIcon.walking.rawValue
        case HKWorkoutActivityType.swimming:
            return AwesomeIcon.swimmer.rawValue
        case HKWorkoutActivityType.volleyball:
            return AwesomeIcon.volleyballBall.rawValue
        case HKWorkoutActivityType.surfingSports:
            return AwesomeIcon.snowboarding.rawValue
        default:
            /// Idea: automatically try to cast `HKWorkoutActivityType` into AwesomeIcon String
            return AwesomeIcon.heart.rawValue
        }
    }

    /// Prints a given duration (in seconds) in a good readable format (hh:mm:ss)
    public static func formatDuration(time: Int, full: Bool = false) -> String {
        let seconds = Int(time)
        if full {
            return String(format: "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        }
        return seconds < 60*60 // <1h --> mm:ss
            ? String(format: "%02d:%02d", seconds / 60, seconds % 60)
            : seconds > 60 * 60 * 100 // >100h --> h"h"
            ? String(format: "%dh", seconds / 3600)
            : String(format: "%1d:%02dh", seconds / 3600, (seconds % 3600) / 60) // h:mm"h"
    }

    /// Duplicate of `formatDuration(Int, Bool)` to avoid casting views
    public static func formatDuration(time: Double, full: Bool = false) -> String {
        formatDuration(time: Int(time), full: full)
    }

    /// Prints a distance (which comes from the server in meters) rounded to one after-decimal number and in km
    ///
    /// To save space, distances >=100km will be truncated to the last full km
    public static func formatDistance(distance: Double) -> String {
        String(format: (distance >= 100 ? "%.0f km" : "%.1f km"), distance / 1000)
    }
}
