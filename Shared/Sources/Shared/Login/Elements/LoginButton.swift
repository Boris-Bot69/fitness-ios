//
//  LoginButton.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 16.05.21.
//

import SwiftUI

public struct LoginButton: View {
    @ObservedObject var viewModel: LoginViewModel
    public var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: viewModel.login) {
                    Text(NSLocalizedString("Login", bundle: .module, comment: "Login Button Text"))
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.white)
                }
                Spacer()
            }.padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color("LoginButtonColor", bundle: .module))
                )
        }
    }
}

struct LoginButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                ZStack {
                    Color(UIColor.systemBackground)
                    LoginButton(viewModel: LoginViewModel(LoginUserModel()))
                }.colorScheme(colorScheme)
            }
        }
    }
}
