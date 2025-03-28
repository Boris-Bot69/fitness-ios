//  LoginView.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 16.05.21.
//

import SwiftUI

public struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    public var body: some View {
        VStack {
            HStack {
                Image("MRILogo", bundle: .module)
                    .padding(.horizontal, 10)
                Image("RunnerIcon", bundle: .module)
                    .scaleToFit(height: 50, alignment: .center)
                    .padding(.horizontal, 10)
            }
            LoginTextFields(viewModel: viewModel)
            LoginButton(viewModel: viewModel)
                .padding(.top, 15)
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage.localized)
                    .foregroundColor(Color("ErrorColor", bundle: .module))
            }
        }
        .padding()
        .background(
            Color("LoginBackgroundColor", bundle: .module)
                .opacity(0.80)
                .cornerRadius(12)
        )
    }

    public init(_ model: LoginUserModel) {
        viewModel = LoginViewModel(model)
    }
}

struct LoginView_Previews: PreviewProvider {
    private static let model = LoginUserModel()

    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            LoginScreen(userModel: model)
                .colorScheme(colorScheme)
        }
    }
}
