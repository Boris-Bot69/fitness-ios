//
//  CredentialOverlay.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 01.07.21.
//

import SwiftUI

protocol CredentialsViewModel: ObservableObject {
    var username: String { get }
    var password: String { get }
    var showCredentials: Bool { get set }
}

struct Credentials<V: CredentialsViewModel>: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.refresh) private var refresh
    @ObservedObject var viewModel: V
    
    var body: some View {
        ZStack {
            if viewModel.showCredentials {
                Color.gray.opacity(0.4).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Patient registered successfully!".localized)
                        .font(.system(size: 24))
                        .bold()
                    Spacer().frame(height: 34)
                    Text("Username: \(viewModel.username)".localized)
                        .font(.system(size: 22))
                    Spacer().frame(height: 10)
                    Text("Password: \(viewModel.password)".localized)
                        .font(.system(size: 22))
                    Spacer().frame(height: 50)
                    Button("Okay".localized) {
                        viewModel.showCredentials = false
                        refresh()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 22))
                }
                .frame(width: 400, height: 250, alignment: .center)
                .background(Color.primary.colorInvert().opacity(0.6))
                .cornerRadius(25)
            }
        }
    }
}

class DummyCredentialsViewModel: CredentialsViewModel {
    var showCredentials = true
    var username: String = "doctor"
    var password: String = "password"
}

struct CredentialOverlay_Previews: PreviewProvider {
    static var previews: some View {
        Credentials(viewModel: DummyCredentialsViewModel())
    }
}
