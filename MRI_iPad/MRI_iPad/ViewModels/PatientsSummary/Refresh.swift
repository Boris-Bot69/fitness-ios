//
//  RefreshAction.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 10.07.21.
//

import Foundation
import SwiftUI

struct Refresh: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var refresh: () -> Void {
        get { self[Refresh.self] }
        set { self[Refresh.self] = newValue }
    }
}
