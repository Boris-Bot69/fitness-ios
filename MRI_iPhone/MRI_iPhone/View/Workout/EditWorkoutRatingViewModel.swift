//
//  EditWorkoutRatingViewModel.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 02.06.21.
//

import Foundation
import SwiftUI
import FontAwesomeSwiftUI
import Shared

class EditWorkoutRatingViewModel: ObservableObject {
    @Published var intensity = 0.0
    @Published var rating: WorkoutRating = .notset
    @Published var comment = "" {
        didSet {
            if comment.count > commentCharacterLimit {
                comment = oldValue
            }
            // prevent more than 1 empty line between characters
            if comment.suffix(3) == "\n\n\n" {
                comment = String(comment.prefix(oldValue.count))
            }
        }
    }
    @Published var loaded = false

    let commentCharacterLimit = 200

    var workoutId: Int
    private weak var model: ServerWorkoutModel?
    var workout: WorkoutsOverviewWorkoutMediator? {
        model?.workout(workoutId)
    }

    init(_ model: ServerWorkoutModel, workoutId: Int) {
        self.model = model
        self.workoutId = workoutId
        updateStates()
    }

    func updateStates() {
        guard let workout = workout, !loaded else {
            return
        }
        self.intensity = workout.intensity

        switch workout.rating {
        case 1:
            self.rating = .bad
        case 2:
            self.rating = .medium
        case 3:
            self.rating = .good
        default:
            self.rating = .notset
        }

        self.comment = workout.comment

        self.loaded = true
    }

    func save() {
        guard let model = model,
            let workout = workout else {
            print("Error: preconditions failed")
            return
        }
        model.update(workout.workoutId, intensity: intensity, comment: comment, rating: rating)
        print("\(workout.workoutId): intensity=\(intensity), comment=\(comment), rating=\(rating)")
        let modelWorkout = model.workouts.first { modelWorkout in
            modelWorkout.workoutId == workout.workoutId
        }
        print("New Rating: \(modelWorkout?.rating ?? -1)")
    }
}
