//
//  ContentView.swift
//  tumsm
//
//  Created by Denis Graipel on 27.04.21.
//

import SwiftUI
import HealthKit
import Shared

struct ContentView: View {
    @State var presentAccountAlert = false

    @State private var healthAccessGiven: Bool

    @ObservedObject var userModel: LoginPatientModel
    
    init(userModel: LoginPatientModel) {
        self.userModel = userModel
        // required to initialize State vars in `init`
        _healthAccessGiven = State(initialValue: false)
    }
    
    init(userModel: LoginPatientModel, healthAccessGiven: Bool) {
        self.userModel = userModel
        self._healthAccessGiven = State(initialValue: healthAccessGiven)
    }
    
    var body: some View {
        if userModel.token == nil || userModel.patientId == nil {
            return AnyView(LoginScreen(userModel: userModel))
        } else {
            guard let patientInfo = userModel.patientInfo else {
                return AnyView(
                    ProgressView()
                        .onAppear {
                            guard let patientId = userModel.patientId else {
                                return
                            }
                            userModel.getPatientInfo(patientId: patientId)
                        }
                )
            }
            return AnyView(NavigationView {
                Group {
                    if !healthAccessGiven {
                        Text("No Health Access Given!")
                    } else {
                        WorkoutList(
                            fetchStartDate: patientInfo.treatmentStarted,
                            fetchEndDate: patientInfo.treatmentFinished
                        )
                    }
                }
                .navigationBarTitle("Workouts")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        AccountButton(presentAccountAlert: $presentAccountAlert)
                    }
                }
                .alert(isPresented: $presentAccountAlert) {
                    AccountButton.logoutAlert(userModel)
                }
                .onAppear {
                    HealthKitManager.requestAuthorization { auth, _ in
                        healthAccessGiven = auth
                    }
                }
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let userModel = LoginPatientModel()
        userModel.token = "test-token"
        
        let model = MockServerWorkoutModel()
        model.serverFetchLoadingState = .success
        
        // preview light & dark mode at the same time
        return Group {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                ContentView(userModel: LoginPatientModel(), healthAccessGiven: true)
                    .colorScheme(colorScheme)
            }
            ContentView(userModel: userModel, healthAccessGiven: true)
                .colorScheme(.light)
        }.environmentObject(model as ServerWorkoutModel)
        // preview iPhone & iPad at the same time
//        ContentView(userModel: LoginUserModel())
//            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (5th generation)"))
//            .previewLayout(.fixed(width: 1366, height: 1024))
//            .environmentObject(MockServerWorkoutModel() as ServerWorkoutModel)
//        ContentView(userModel: LoginUserModel())
//            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
//            .environmentObject(MockServerWorkoutModel() as ServerWorkoutModel)
    }
}
