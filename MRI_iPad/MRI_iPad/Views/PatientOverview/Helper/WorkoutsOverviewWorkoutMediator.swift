//
//  WorkoutsOverviewWorkoutMediator.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 02.07.21.
//

import Foundation
import Shared
import SwiftUI

extension WorkoutsOverviewWorkoutMediator {
    var cellColor: Color {
        switch self.mainHeartRateSegment {
        case 0:
            return Color.Blue
        case 1:
            return Color.LightBlue
        case 2:
            return Color.Green
        case 3:
            return Color.Orange
        case 4:
            return Color.Red
        default:
            return Color.black
        }
    }
    
    var ratingColor: Color {
        switch self.rating {
        case 1:
            return .Red
        case 2:
            return .Orange
        case 3:
            return .Green
        default:
            return .Grey
        }
    }
}
