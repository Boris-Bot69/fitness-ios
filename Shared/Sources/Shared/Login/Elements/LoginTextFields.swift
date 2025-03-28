//
//  LoginTextFields.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 16.05.21.
//

import SwiftUI

public struct LoginTextFields: View {
    @ObservedObject var viewModel: LoginViewModel
    public var body: some View {
        VStack(spacing: 10) {
            TextField("Username".localized, text: $viewModel.username)
                .textContentType(.username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("BackgroundColor", bundle: .module))
                )
            SecureField("Password".localized, text: $viewModel.password)
                .textContentType(.password)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("BackgroundColor", bundle: .module))
                )
        }
    }

    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
}

struct LoginTextFields_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                ZStack {
                    Color(UIColor.systemBackground)
                    LoginTextFields(viewModel: LoginViewModel(LoginUserModel()))
                }.colorScheme(colorScheme)
            }
        }
        .previewLayout(.fixed(width: 400, height: 300))
    }
}
