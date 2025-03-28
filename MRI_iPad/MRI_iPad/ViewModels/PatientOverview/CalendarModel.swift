//
//  CalendarModel.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 17.05.21.
//
//swiftlint:disable force_unwrapping
import Foundation

class CalendarModel: ObservableObject {
    var calendar = Foundation.Calendar(identifier: .iso8601)
    @Published var currentMonth: Date
    @Published var dateSheet: [Date: [Date]] = [:]
    var calNavigation: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL YYYY"
        return dateFormatter.string(from: currentMonth)
    }
    
    init() {
        self.currentMonth = Date().firstDayOfTheMonth
        self.getSheet()
    }
    
    func prevMonth() {
        let component = DateComponents(month: -1)
        self.currentMonth = calendar.date(byAdding: component, to: currentMonth)!
    }
    
    func nextMonth() {
        let component = DateComponents(month: 1)
        self.currentMonth = calendar.date(byAdding: component, to: currentMonth)!
    }
    
    /// Build Sheet as dictionary of Dates/Labels
    func getSheet() {
        dateSheet.removeAll()
        var dateSheet: [Date: [Date]] = [:]
        let startOfMonth: Date = currentMonth
        let endOfMonth = startOfMonth.lastDayOfTheMonth
        
        var firstDayOfTheWeek = startOfMonth.firstDayOfTheWeek
        let fromCalendarWeek = startOfMonth.calendarweek
        var toCalendarWeek = endOfMonth.calendarweek
        if startOfMonth.calendarweek > endOfMonth.calendarweek {
            //check if the first day of the week still in the same year
            //this implies that the last week of the month is in the next year
            if calendar.isDate(firstDayOfTheWeek, equalTo: startOfMonth, toGranularity: .year) {
                //add the number of weeks in this year to the calendar week
                let numberOfWeeksInYear = calendar.range(of: .weekOfYear, in: .yearForWeekOfYear, for: currentMonth)?.count
                toCalendarWeek = endOfMonth.calendarweek + numberOfWeeksInYear!
            } else {
                toCalendarWeek = endOfMonth.calendarweek + startOfMonth.calendarweek
            }
        }
        (fromCalendarWeek...toCalendarWeek).forEach { _ in
            dateSheet[firstDayOfTheWeek] = (0..<7).map {
                calendar.date(byAdding: .day, value: $0, to: firstDayOfTheWeek) ?? Date()
            }
            firstDayOfTheWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: firstDayOfTheWeek) ?? Date()
        }
        self.dateSheet = dateSheet
    }
}
