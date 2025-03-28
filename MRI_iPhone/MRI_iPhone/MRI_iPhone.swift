//
//  tumsmApp.swift
//  tumsm
//
//  Created by Denis Graipel on 27.04.21.
//

import SwiftUI
import Prototyper
import HealthKit
import FontAwesomeSwiftUI

@main
struct TumsmApp: App {
    @StateObject private var model = ServerWorkoutModel()
    @StateObject private var userModel = LoginPatientModel()

    init() {
        FontAwesome.register()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(userModel: userModel)
                .environmentObject(model as ServerWorkoutModel)
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}
