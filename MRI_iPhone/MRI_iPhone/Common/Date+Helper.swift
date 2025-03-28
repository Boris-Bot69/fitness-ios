//
//  Date+Helper.swift
//  tumsm
//
//  Created by Christopher Schütz on 14.06.21.
//

import Foundation

extension Date {
    func getApiFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        return dateFormatter.string(from: self)
    }
    
    // string date format required by POST /workout/steps
    func getStepsApiFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    /// only if Date that calls the function is the start of the day,
    /// works by adding
    func getEndOfDay() -> Date {
        Calendar.current.date(
            byAdding: .second,
            value: 86399, // 24 * 60 * 60 - 1
            to: self
        ) ?? Date()
    }
}
