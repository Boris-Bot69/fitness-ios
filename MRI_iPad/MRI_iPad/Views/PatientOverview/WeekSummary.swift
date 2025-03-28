//
//  WeekSummary.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 14.06.21.
//

import SwiftUI
import Shared
import Foundation
import FontAwesomeSwiftUI


struct WeekSummary: View {
    @EnvironmentObject var model: Model
    @ObservedObject var summary: WeekSummaryViewModel
    
    init(week: Date, sheet: [Date: [Date]]) {
        summary = WeekSummaryViewModel(week: week, sheet: sheet)
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            if summary.bikeDistance != 0 {
                bikingSummary
            }
            if summary.runningDistance != 0 {
                runningSummary
            }
            Spacer()
        }
        .padding()
        .padding(.top, 10)
        .onAppear {
            summary.setup(model: model)
        }
    }
    
    var runningSummary: some View {
        HStack(alignment: .top) {
            Text(AwesomeIcon.running.rawValue)
                .font(.awesome(style: .solid, size: 27))
                .padding(.trailing, 10)
                .padding(.top, 10)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(String(format: "%.1f", (summary.runningDistance / 1000))) km")
                    .bold()
                Text("\(WorkoutUtils.formatDuration(time: summary.runningTime))")
                    .bold()
            }
        }
    }
    
    var bikingSummary: some View {
        HStack(alignment: .center) {
            Text(AwesomeIcon.biking.rawValue)
                .font(.awesome(style: .solid, size: 27))
                .padding(.trailing, 10)
                .padding(.top, 10)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(String(format: "%.1f", (summary.bikeDistance / 1000))) km")
                    .bold()
                Text("\(WorkoutUtils.formatDuration(time: summary.bikeTime))")
                    .bold()
            }
        }
    }
}

struct WeekSummary_Previews: PreviewProvider {
    static func getMockModelForPatientOverview() -> Model {
        let model = MockModel()
        model.loadPatientsSummaries()
        model.loadPatientWorkoutsOverview(5)
        return model
    }

    static func getWeek() -> [Date: [Date]] {
        let cal = CalendarModel()
        cal.getSheet()
        return cal.dateSheet
    }

    static var previews: some View {
        WeekSummary(week: Date(), sheet: getWeek())
            .environmentObject(PatientOverview_Previews.getMockModelForPatientCalendar() as Model)
            .previewLayout(.fixed(width: 160, height: 160))
    }
}
