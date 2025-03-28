//
//  WorkoutList.swift
//  tumsm
//
//  Created by Christopher Schütz on 24.05.21.
//

import SwiftUI
import Shared

struct WorkoutList: View {
    @EnvironmentObject var model: ServerWorkoutModel
    
    let fetchStartDate: Date
    let fetchEndDate: Date
    
    init (fetchStartDate start: Date = .distantPast, fetchEndDate end: Date = .distantFuture) {
        self.fetchStartDate = start
        self.fetchEndDate = end
    }
    
    var body: some View {
        // guard only for initial loading. Afterwards listen for enter foreground notification
        guard model.serverFetchLoadingState != .notStarted else {
            return AnyView(
                ProgressView()
                    .onAppear {
                        model.fetchData(queryHealthKitAndUpload: true, fetchStartDate: self.fetchStartDate, fetchEndDate: self.fetchEndDate)
                    }
            )
        }
        return AnyView(VStack(spacing: 0) {
            UploadProgress(
                total: $model.numberOfItemsToUpload,
                uploaded: $model.numberOfItemsUploaded,
                failed: $model.numberOfItemsFailedToUpload,
                uploadState: $model.serverUploadLoadingState
            )
            
            List(model.workouts, id: \.workoutId) { workout in
                NavigationLink(destination: EditWorkoutRatingScreen(model, workoutId: workout.workoutId)) {
                    WorkoutCell(id: workout.workoutId)
                }
            }
            // necessary to avoid buggy behavior for long lists:
            // https://www.hackingwithswift.com/articles/210/how-to-fix-slow-list-updates-in-swiftui
            .id(UUID())
        }
        .background(Color.ListBackground.edgesIgnoringSafeArea(.all))
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // using this event listener, because "onAppear" will not be called if
            // the app was ("soft") closed and opened again and thus would not trigger
            // a new healthkit fetch if a workout was recorded when app was closed.
            model.fetchData(queryHealthKitAndUpload: true, fetchStartDate: self.fetchStartDate, fetchEndDate: self.fetchEndDate)
        }
        .onReceive(model.$serverUploadLoadingState) { loadingState in
            if loadingState == .success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    model.fetchData(fetchStartDate: self.fetchStartDate, fetchEndDate: self.fetchEndDate)
                }
            }
        })
    }
}

struct WorkoutList_Previews: PreviewProvider {
    static var previews: some View {
        let modelOne = MockServerWorkoutModel()
        
        modelOne.numberOfItemsToUpload = 3
        modelOne.numberOfItemsUploaded = 3
        modelOne.serverUploadLoadingState = .success
        let viewWithoutUpload = WorkoutList()
            .environmentObject(modelOne as ServerWorkoutModel)
        
        let modelTwo = MockServerWorkoutModel()
        modelTwo.numberOfItemsToUpload = 5
        modelTwo.numberOfItemsUploaded = 3
        modelTwo.numberOfItemsFailedToUpload = 0
        modelTwo.serverUploadLoadingState = .loading
        
        let viewWithUpload = WorkoutList()
            .environmentObject(modelTwo as ServerWorkoutModel)
        
        modelTwo.serverUploadLoadingState = .notStarted
        let viewWhileFetching = WorkoutList()
            .environmentObject(modelTwo as ServerWorkoutModel)
        
        return Group {
            viewWithoutUpload
            viewWithUpload
            viewWhileFetching
        }
    }
}
