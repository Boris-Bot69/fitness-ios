//
//  EditWorkoutRatingScreen.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 01.06.21.
//

import SwiftUI
import FontAwesomeSwiftUI
import Shared

struct EditWorkoutRatingScreen: View {
    @ObservedObject private var model: ServerWorkoutModel
    @ObservedObject private var viewModel: EditWorkoutRatingViewModel

    private var minimumHeightRequired: CGFloat = 600.0

    var workoutId: Int
    var workout: WorkoutsOverviewWorkoutMediator? {
        model.workout(workoutId)
    }
    
    init(_ model: ServerWorkoutModel, workoutId: Int) {
        UITextView.appearance().backgroundColor = .clear
        self.model = model
        self.workoutId = workoutId
        self.viewModel = EditWorkoutRatingViewModel(model, workoutId: workoutId)
    }
    
    var body: some View {
        // Do not obstruct comment field on smaller devices (like iPhone SE 1st Gen)
        // For larger devices, do not use ScrollView, because the overall UI behaves
        // better without it (e.g. view slides up when keyboard appears).
        if useScrollView {
            ScrollView {
                content
            }
        } else {
            content
        }
    }

    private var useScrollView: Bool {
        UIScreen.main.bounds.height < minimumHeightRequired
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 35) {
            WorkoutInfoView(workoutId: workoutId)
            EditWorkoutRatingPicker(rating: $viewModel.rating)
            EditWorkoutIntensitySlider(intensity: $viewModel.intensity)
            EditWorkoutComment(text: $viewModel.comment)
            Spacer()
        }
        .foregroundColor(.FontPrimary)
        .padding()
        .padding(.top, 5)
        .navigationBarTitle(Text("Feedback"), displayMode: .inline)
        .onDisappear {
            viewModel.save()
        }
    }
}

struct EditWorkoutRatingScreen_Previews: PreviewProvider {
    private static let model = MockServerWorkoutModel()

    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                EditWorkoutRatingScreen(model, workoutId: model.workouts[3].workoutId)
            }
            .colorScheme(colorScheme)
        }.environmentObject(model as ServerWorkoutModel)
    }
}
