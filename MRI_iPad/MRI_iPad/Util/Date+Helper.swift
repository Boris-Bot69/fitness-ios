//
//  Date+Helper.swift
//  DoctorsApp
//
//  Created by Christopher Schütz on 07.06.21.
//

import Foundation

extension Date {
    /// Instantiate date using `yyyy-MM-dd`-formatted string
    init(_ dateString: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateStringFormatter.date(from: dateString) ?? Date()
        self.init(timeInterval: 0, since: date)
    }

    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)

        return  calendar.date(from: components) ?? Date()
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        
        return Calendar(identifier: .gregorian)
            .date(byAdding: components, to: startOfMonth) ?? Date()
    }
     
    var asDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
    
    var asTimeString: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: self)
    }

    var tomorrow: Date {
        Date().advanced(by: 60 * 60 * 24)
    }

    var yesterday: Date {
        Date().advanced(by: -60 * 60 * 24)
    }
}

extension Optional where Wrapped == Date {
    var asDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        guard let date = self else {
            return ""
        }
        return dateFormatter.string(from: date)
    }
}

extension Date {
    var calendar: Calendar { Calendar(identifier: .iso8601) }

    var weekday: Int {
        (calendar.component(.weekday, from: self) - calendar.firstWeekday + 7) % 7 + 1
    }
    
    var calendarweek: Int {
        calendar.component(.weekOfYear, from: self)
    }
    
    var firstDayOfTheWeek: Date {
        calendar.date(byAdding: .day, value: 1 - self.weekday, to: self) ?? self
    }
    
    var lastDayOfTheWeek: Date {
        calendar.date(byAdding: .day, value: 7 - self.weekday, to: self) ?? self
    }
    
    var firstDayOfTheMonth: Date {
        let component = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: component) ?? Date()
    }
    
    var lastDayOfTheMonth: Date {
        let endOfMonthComponents = DateComponents(month: 1, day: -1)
        return calendar.date(byAdding: endOfMonthComponents, to: self) ?? Date()
    }
}
