//
//  Gender.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 16.07.21.
//
//swiftlint:disable identifier_name

import Foundation
import SwiftUI

enum Gender: String, Equatable, CaseIterable {
    case m
    case f
    case d
    
    var name: String {
        switch self {
        case .m:
            return "male"
        case .f:
            return "female"
        case .d:
            return "diverse"
        }
    }
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(name) }
}
