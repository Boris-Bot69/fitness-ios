//
//  EditPatientTrainingZones.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 14.07.21.
//

import Foundation
import SwiftUI
import HealthKit
import Shared

class EditPatientTrainingZones: ObservableObject {
    let units = [Unit.bpm, Unit.kmh]
    let workoutTypes = [HKWorkoutActivityType.running, HKWorkoutActivityType.cycling]
    @Published var values: [String] = ["", "", "", ""]
    @Published var workoutType: HKWorkoutActivityType?
    @Published var unit: Unit?
    
    init(values: [String] = ["", "", "", ""], workoutType: Int? = nil, unit: Unit? = nil) {
        self.values = values
        if let uint = workoutType {
            self.workoutType = HKWorkoutActivityType(rawValue: UInt(uint))
        }
        self.unit = unit
    }
    
    lazy var trainingZonesValidator: ValidationPublisher = {
        ValidationPublishers.combineAll(
            $values.notEmptyValidator("One or more training zones values are empty".localized),
            $values.intElementsValidator("All training zones values must be a number".localized),
            $values.validElementsValidator("All training zones values must be 0 - 999".localized),
            $values.orderedElementsValidator("Training zones value cannot be lower than its predecessor!".localized),
            $workoutType.notEmptyValidator("Workout type must not be empty".localized)
                .prepend(.failure(message: "Workout type must not be empty".localized))
                .eraseToAnyPublisher(),
            $unit.notEmptyValidator("Unit must not be empty".localized)
                .prepend(.failure(message: "Unit must not be empty".localized))
                .eraseToAnyPublisher()
        )
    }()
}

extension EditPatientTrainingZones: Hashable {
    static func == (lhs: EditPatientTrainingZones, rhs: EditPatientTrainingZones) -> Bool {
        lhs.values == rhs.values && lhs.workoutType == rhs.workoutType && lhs.unit == rhs.unit
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(values)
        hasher.combine(workoutType)
        hasher.combine(unit)
    }
}

enum Unit: String {
    case bpm = "HEARTRATE"
    case kmh = "SPEED"
    
    var name: String {
        switch self {
        case .bpm:
            return "bpm"
        case .kmh:
            return "km/h"
        }
    }
}
