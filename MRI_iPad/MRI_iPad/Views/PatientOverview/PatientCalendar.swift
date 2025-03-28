//
//  PatientCalendar.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 15.05.21.
//

//swiftlint:disable force_unwrapping
import SwiftUI
import Shared


struct PatientCalendar: View {
    @ObservedObject var calendarModel: CalendarModel
    @EnvironmentObject var model: Model

    /// Headings for `columns`
    let headings = [
        "Monday".localized, "Tuesday".localized, "Wednesday".localized,
        "Thursday".localized, "Friday".localized, "Saturday".localized, "Sunday".localized, "", "∑"
    ]
    
    /// Headings for `columnsMinimal`
    var headingsMinimal: [String] {
        headings.filter { title in
            title.count > 2
        }
    }

    init(_ model: CalendarModel) {
        self.calendarModel = model
    }

    /// Full set of calendar columns (Calendar week, Weekdays, Divider, Weekly summary)
    ///
    /// Use these for large devices in landscape orientation!
    var columns: [GridItem] {
        [
            .init(.flexible(minimum: 40, maximum: 40), spacing: 0),  // calendar week
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // Mo
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // Tu
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // We
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // Th
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // Fr
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // Sa
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // Su
            .init(.fixed(4), spacing: 0),                            // divider
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0)  // weekly summary
        ]
    }

    /// Minimal set of calendar columns (weekdays only)
    ///
    /// Use these for smaller devices or in portrait orientation!
    var columnsMinimal: [GridItem] {
        [
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // Mo
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // Tu
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // We
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // Th
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // Fr
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0), // Sa
            .init(.flexible(minimum: 50, maximum: 300), spacing: 0) // Su
        ]
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                LazyVGrid(columns: sufficientWidth(geometry) ? columns : columnsMinimal, spacing: 0) {
                    // Headings
                    if sufficientWidth(geometry) {
                        Text("")  // calendar week column doesn't need a heading
                    }
                    ForEach(sufficientWidth(geometry) ? headings : headingsMinimal, id: \.self) { item in
                        Text(item)
                    }
                    .padding(.vertical, 8)
                    .font(.headline)
                    .foregroundColor(.FontPrimary)
                }
                .background(Color.BackgroundGrey)
                .border(width: 1, edges: [.bottom], color: .LightGrey)

                switch model.patientWorkoutsOverviewLoadingState {
                case .loading, .notStarted, .loadingFailed:
                    loadingText
                case .loadedSuccessfully:
                    ScrollView(.vertical) {
                        LazyVGrid(columns: sufficientWidth(geometry) ? columns : columnsMinimal, spacing: 0) {
                            ForEach(calendarModel.dateSheet.keys.sorted(by: <), id: \.self) { key in
                                if sufficientWidth(geometry) {
                                    weekCell(String(key.calendarweek))
                                        // hide horizontal gridline in calendar week column
                                        .border(width: 1, edges: [.bottom], color: .DarkBlue)
                                }
                                
                                ForEach(calendarModel.dateSheet[key]!, id: \.self) { idx in
                                    CalendarCell(
                                        date: idx,
                                        calendar: calendarModel
                                    )
                                    // 140: 2 workouts look nice
                                    // 165: 3 workouts fit without scrolling
                                    .frame(minHeight: 140, maxHeight: 165)
                                    .border(width: 1, edges: borderEdges(idx), color: .LightGrey)
                                }
                                if sufficientWidth(geometry) {
                                    Color.DarkBlue  // separator
                                    WeekSummary(week: key, sheet: calendarModel.dateSheet)
                                        .border(width: 1, edges: [.bottom], color: .LightGrey)
                                }
                            }
                        }
                        .font(.body)
                        .background(Color.BackgroundGrey)
                    }
                }
            }
        }
    }

    /// Determine from current geometry, whether to use minimal or full calendar.
    ///
    /// Return true, if width is less than 1024.
    ///
    /// An alternative solution outlined in [1] did work similarly, but did not yield the correct
    /// orientation on app start. Orientation was only set after first rotation and initializing it
    /// based on `UIDevice.current.orientation` didn't work.
    ///
    /// [1] https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-device-rotation
    func sufficientWidth(_ geometry: GeometryProxy) -> Bool {
        geometry.size.width >= 1024
    }

    /// Return borders based on `Date`, so that every CalendarCell only has a single border.
    func borderEdges(_ idx: Date) -> [Edge] {
        if idx.weekday == 7 {
            return [.bottom]
        } else {
            return [.bottom, .trailing]
        }
    }

    var loadingText: some View {
        switch model.patientWorkoutsOverviewLoadingState {
        case .loading:
            return Text("Loading Overview Information")
        case .notStarted:
            return Text("Not Started")
        case .loadingFailed:
            return Text("Loading Failed")
        default:
            return Text("Loading State Error")
        }
    }

    func weekCell(_ label: String) -> some View {
        ZStack {
            Color.DarkBlue
            Text(label)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
        }
    }
}


struct PatientCalendar_Previews: PreviewProvider {
    static func getMockModelForPatientOverview() -> Model {
        let model = MockModel()
        model.loadPatientsSummaries()
        model.loadPatientWorkoutsOverview(5)
        return model
    }

    static var previews: some View {
        Group {
            PatientCalendar(
                CalendarModel()
            )
            .environmentObject(PatientCalendar_Previews.getMockModelForPatientOverview() as Model)
            // iPad Pro 12.9" landscape viewport
            .previewLayout(.fixed(width: 1366, height: 1024))
        }
    }
}
