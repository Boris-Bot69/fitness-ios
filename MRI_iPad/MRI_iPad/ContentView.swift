//
//  ContentView.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 06.05.21.
//

import SwiftUI
import Shared


struct ContentView: View {
    @State var presentAccountAlert = false
    @State private var presentServerView = false

    @ObservedObject var userModel: LoginDoctorModel

    var body: some View {
        if userModel.token == nil {
            LoginScreen(userModel: userModel)
        } else {
            NavigationView {
                VStack {
                    PatientsSummary(viewModel: PatientsSummaryViewModel())
                }
                .navigationBarTitle("", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        AccountButton(presentAccountAlert: $presentAccountAlert)
                    }
                }
            }
            // Remove the sidebar
            .navigationViewStyle(StackNavigationViewStyle())
            .alert(isPresented: $presentAccountAlert) {
                AccountButton.logoutAlert(userModel)
            }
            .edgesIgnoringSafeArea(.top)
            .accentColor(.DarkBlue)
            .foregroundColor(.FontPrimary)
        }
    }

    static var rangeGraphView: some View {
        RangeGraph(zoneValues: [20, 30, 15, 15, 20])
    }
}

struct ContentView_Previews: PreviewProvider {
    private static var model = LoginDoctorModel("Timo", token: "preview-token")
    static var previews: some View {
        ContentView(userModel: model)
    }
}
