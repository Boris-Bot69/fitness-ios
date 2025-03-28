//
//  AccountButton.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 25.05.21.
//

import SwiftUI

// MARK: - AccountButton
/// Button that is used to provide logout function
public struct AccountButton: View {
    @Binding var presentAccountAlert: Bool

    public var body: some View {
        Button(action: { self.presentAccountAlert = true }) {
            Image(systemName: "person.crop.circle")
        }
    }

    public static func logoutAlert(_ model: LoginUserModel) -> Alert {
        Alert(title: Text("Account".localized),
              message: Text("You are logged in as: ".localized + model.username),
              primaryButton: .destructive(Text("Logout".localized), action: model.logout),
              secondaryButton: .default(Text("OK".localized)))
    }

    public init(presentAccountAlert: Binding<Bool>) {
        self._presentAccountAlert = presentAccountAlert
    }
}

struct AccountButton_Previews: PreviewProvider {
    @State private static var presentAccountAlert = Binding.constant(true)

    static var previews: some View {
        AccountButton(presentAccountAlert: presentAccountAlert)
            .alert(isPresented: presentAccountAlert) {
                AccountButton.logoutAlert(LoginUserModel())
            }
    }
}
