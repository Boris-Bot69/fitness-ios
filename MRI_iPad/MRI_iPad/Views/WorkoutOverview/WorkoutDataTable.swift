//
//  DataTable.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 04.06.21.
//

import SwiftUI
import Shared

struct WorkoutDataTable: View {
    @EnvironmentObject var model: Model
    
    var columns: [GridItem] = [
        .init(.flexible(minimum: 50, maximum: 100)),
        .init(.flexible(minimum: 50, maximum: 300)),
        .init(.flexible(minimum: 50, maximum: 300)),
        .init(.flexible(minimum: 50, maximum: 300)),
        .init(.flexible(minimum: 50, maximum: 400)),
        .init(.flexible(minimum: 50, maximum: 250)),
        .init(.flexible(minimum: 50, maximum: 250))
    ]
    
    var headings = [
        "No.".localized,
        "Ø Heart rate".localized,
        "Max. Heart rate".localized,
        "Ø Speed".localized,
        "Max. Speed".localized,
        "Duration".localized,
        "Distance".localized
    ]
    
    var body: some View {
        if model.patientDetailedWorkoutLoadingState == .loadedSuccessfully {
            if let workout = model.patientDetailedWorkout {
                if !workout.kilometerPace.isEmpty {
                    VStack(spacing: 0) {
                        LazyVGrid(columns: columns, alignment: .leading) {
                            ForEach(headings, id: \.self) { item in
                                Text("\(item)")
                                    .font(.headline)
                                    .foregroundColor(.FontPrimary)
                                    .frame(height: 30)
                            }
                        }
                        .padding(.leading, 20)
                
                        ForEach((0..<workout.kilometerPace.count)) { index in
                            if index.isMultiple(of: 2) {
                                workoutTableRow(workout, index: index)
                                    .padding()
                                    .border(width: 1, edges: self.getEdgesForRow(workout, index: index), color: Color.LightGrey)
                            } else {
                                workoutTableRow(workout, index: index)
                                    .padding()
                                    .border(width: 1, edges: self.getEdgesForRow(workout, index: index), color: Color.LightGrey)
                                    .background(Color.BackgroundGrey)
                            }
                        }
                    }
                    .padding()
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    func getEdgesForRow(_ workout: GetWorkoutMediator, index: Int) -> [Edge] {
        if workout.kilometerPace.count == index + 1 {
            return [.leading, .trailing, .top, .bottom]
        }
        return [.leading, .trailing, .top]
    }
    
    func workoutTableRow(_ workout: GetWorkoutMediator, index: Int) -> some View {
        let pace = workout.kilometerPace[index]
        // Precalculate for better readability of code: Add 0 before Seconds e.g. :07 instead of :7
        let seconds = Int(pace.seconds) < 10 ? "0\(Int(pace.seconds))" : "\(Int(pace.seconds))"
        
        return LazyVGrid(columns: columns, alignment: .leading) {
            Group {
                Text("\(index + 1)")
                    .padding(.leading, 5)
                Text("\(Int(pace.avgHeartRate ?? 0.0)) bpm")
                    .padding(.leading, 5)
                Text("\(Int(pace.maxHeartRate ?? 0.0)) bpm")
                    .padding(.leading, 7)
                Text("\(String(format: "%.1f", pace.avgSpeed ?? 0.0)) km/h")
                    .padding(.leading, 7)
                Text("\(String(format: "%.1f", pace.maxSpeed ?? 0.0)) km/h")
                    .padding(.leading, 10)
                Text("\(pace.minutes):\(seconds)")
                    .padding(.leading, 15)
                Text("1 km")
                    .padding(.leading, 15)
            }
            .font(.headline)
            .foregroundColor(.FontPrimary)
        }
    }
}

struct WorkoutDataTable_Previews: PreviewProvider {
    static func getMockModel() -> Model {
        let model = MockModel()
        model.loadDetailedWorkout(identifier: 84)
        return model
    }
    
    static var previews: some View {
        Group {
            WorkoutDataTable()
            .environmentObject(WorkoutDataTable_Previews.getMockModel() as Model)
                // iPad Pro 12.9" landscape viewport
                .previewLayout(.fixed(width: 1366, height: 1024))
        }
    }
}
