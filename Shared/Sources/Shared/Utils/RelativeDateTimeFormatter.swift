//
//  RelativeDateTimeFormatter.swift
//  
//
//  Created by Jannis Mainczyk on 16.06.21.
//

import Foundation

extension RelativeDateTimeFormatter {
    /// Gives a relative date description.
    ///
    /// Example: 45 minutes ago
    static var namedAndSpelledOut: RelativeDateTimeFormatter {
        let relativeDateTimeFormatter = RelativeDateTimeFormatter()
        relativeDateTimeFormatter.dateTimeStyle = .named
        relativeDateTimeFormatter.unitsStyle = .full
        return relativeDateTimeFormatter
    }
}

extension DateFormatter {
    /// Formatter that includes the date as well as the time.
    ///
    /// Example: September 3, 2018 at 3:38 PM
    public static let dateAndTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()

    /// Formatter that includes only the date.
    ///
    /// Example: 9/3/18
    public static let onlyDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
}
