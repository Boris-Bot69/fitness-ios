//
//  Double+Round.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 08.07.21.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
