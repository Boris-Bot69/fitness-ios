//
//  DateFormatter.swift
//  MRIChart
//
//  Created by Daniel Nugraha on 12.05.21.
//

import Foundation
import Charts

/// Format the double values (in seconds) provided in xAxis to time format hh:mm
class ChartXAxisFormatter: NSObject, AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let time = Int(value)
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return String(format: "%0.2d:%0.2d", hours, minutes)
    }
}

class ChartKilometerFormatter: NSObject, AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        String(Int(value) / 1000)
    }
}
