//
//  Sample.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 28.05.21.
//

import Foundation

/// Combine time and distance values for dynamic switching of Chart's xAxis unit
struct Sample: Equatable {
    let secondsSinceStart: Double
    let value: Double
    let distance: Double
    
    static func == (lhs: Sample, rhs: Sample) -> Bool {
        lhs.value == rhs.value && lhs.secondsSinceStart == rhs.secondsSinceStart && lhs.distance == rhs.distance
    }
}

extension Sample: Codable, Hashable {
}
