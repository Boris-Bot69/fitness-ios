//
//  EditWorkoutRatingPicker.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 11.06.21.
//

import SwiftUI

enum WorkoutRating: String, CaseIterable, Identifiable {
    case notset
    case bad
    case medium
    case good

    var id: String { self.rawValue }

    var value: Int {
        switch self {
        case .notset:
            return 0
        case .bad:
            return 1
        case .medium:
            return 2
        case .good:
            return 3
        }
    }

    var text: String {
        switch self {
        case .good:
            return NSLocalizedString("good", comment: "WorkoutRating.good")
        case .medium:
            return NSLocalizedString("medium", comment: "WorkoutRating.medium")
        case .bad:
            return NSLocalizedString("bad", comment: "WorkoutRating.bad")
        case .notset:
            return NSLocalizedString("not set", comment: "WorkoutRating.notset")
        }
    }

    var icon: String {
        switch self {
        case .good:
            return "😁"  // choices: 😁😃😊🙂😍🥳🤩
        case .medium:
            return "😐"  // choices:
        case .bad:
            return "☹️"  // choices: 😞😔🙁☹️😣😖😫😩😢🥵😓
        case .notset:
            // idea: display emoji based on user's gender 🤷‍♀️/🤷‍♂️/🤷
            return "🤷"
        }
    }
}

struct EditWorkoutRatingPicker: View {
    @Binding var rating: WorkoutRating

    init(rating: Binding<WorkoutRating>) {
        self._rating = rating

        // increase text size of SegmentedPicker elements
        // see https://www.hackingwithswift.com/forums/swiftui/segmented-controller/4181
        UISegmentedControl.appearance().setTitleTextAttributes([.font: UIFont.preferredFont(forTextStyle: .headline)], for: .normal)

        // increase size of selected element even more
        UISegmentedControl.appearance().setTitleTextAttributes([.font: UIFont.preferredFont(forTextStyle: .title1)], for: .selected)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .bottom) {
                Text("Workout Rating").font(.headline)
                Spacer()
                Text(rating.text)
                    .font(.subheadline)
                    .foregroundColor(.FontLight)
            }
            Picker("Workout Rating", selection: $rating) {
                ForEach(WorkoutRating.allCases, id: \.self) { rating in
                    Text(rating.icon)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct EditWorkoutRatingPicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StatefulPreviewWrapper(WorkoutRating.good) {
                EditWorkoutRatingPicker(rating: $0)
            }.padding()
            Spacer()
        }
    }
}
