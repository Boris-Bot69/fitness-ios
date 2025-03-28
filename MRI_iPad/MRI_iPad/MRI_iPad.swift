//
//  DoctorsAppApp.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 06.05.21.
//

import SwiftUI
import Prototyper
import FontAwesomeSwiftUI
import Shared

@main
struct DoctorsAppApp: App {
    init() {
        FontAwesome.register()
    }
    
    @StateObject var userModel = LoginDoctorModel()
    
    // without to api
//    @StateObject var model = MockModel()
    // with connection to api
    @StateObject var model = ServerModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(userModel: userModel)
                .prototyper(PrototyperSettings.default)
                .environmentObject(model as Model)
        }
    }
}
