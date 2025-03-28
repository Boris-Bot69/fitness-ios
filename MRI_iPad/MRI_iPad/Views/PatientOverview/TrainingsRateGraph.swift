//
//  TrainingsRateGraph.swift
//  DoctorsApp
//
//  Created by Jannis Mainczyk on 06.07.21.
//

import SwiftUI

/// Visualize the weekly progress of a patient with his exercise plan
struct TrainingsRateGraph: View {
    let workoutsPlanned: Int
    let workoutsRecorded: Int
    let alignment: Alignment?
    let padding: CGFloat

    var stretch: Bool {
        alignment != nil
    }

    init(
        workoutsPlanned: Int,
        workoutsRecorded: Int,
        alignment: Alignment? = nil,
        padding: CGFloat = 8
    ) {
        self.workoutsPlanned = workoutsPlanned
        self.workoutsRecorded = workoutsRecorded
        self.alignment = alignment
        self.padding = padding
    }

    var percentage: Int {
        guard workoutsPlanned != 0 else {
            return 100
        }
        return Int(100 * Double(workoutsRecorded) / Double(workoutsPlanned))
    }

    var backgroundColor: Color {
        switch percentage {
        case ..<50:
            return Color.BackgroundRed
        case 50..<100:
            return Color.BackgroundOrange
        case 100...:
            return Color.BackgroundGreen
        default:
            return Color.BackgroundGrey
        }
    }

    var body: some View {
        HStack {
            if stretch && alignment != .leading {
                Spacer()
            }
            Text("\(workoutsRecorded)/\(workoutsPlanned)")
            Text("(\(percentage)%)")
            if stretch && alignment != .trailing {
                Spacer()
            }
        }
        .padding(padding)
        .frame(height: 38)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}

struct TrainingsRateGraph_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TrainingsRateGraph(workoutsPlanned: 4, workoutsRecorded: 0)
            TrainingsRateGraph(workoutsPlanned: 4, workoutsRecorded: 1, alignment: .center)
            TrainingsRateGraph(workoutsPlanned: 4, workoutsRecorded: 2, alignment: .leading)
            TrainingsRateGraph(workoutsPlanned: 4, workoutsRecorded: 3, alignment: .trailing)
            TrainingsRateGraph(workoutsPlanned: 4, workoutsRecorded: 4, alignment: .center)
                .frame(width: 200)
            TrainingsRateGraph(workoutsPlanned: 4, workoutsRecorded: 5, padding: 20)
            TrainingsRateGraph(workoutsPlanned: 4, workoutsRecorded: 6, alignment: .center, padding: 20)
        }
        .padding()
        .previewLayout(PreviewLayout.fixed(width: 300, height: 400))
    }
}
