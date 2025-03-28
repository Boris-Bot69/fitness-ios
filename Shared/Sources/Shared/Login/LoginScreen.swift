//
//  LoginScreen.swift
//  
//
//  Created by Jannis Mainczyk on 22.06.21.
//

import SwiftUI

public struct LoginScreen: View {
    @ObservedObject var userModel: LoginUserModel

    public init(userModel: LoginUserModel) {
        self.userModel = userModel
    }

    public var body: some View {
        // Placing all elements in a ZStack allow us to place a layer with
        // the copyright info at the bottom, ignoring the keyboard safe area
        // while still maintaining spacer flexibility on the user input layer.
        // - https://developer.apple.com/forums/thread/658432
        ZStack {
            VStack {
                Spacer()
                LoginView(userModel)
                    .padding(.horizontal)
                    .frame(maxWidth: 400, alignment: .center)
                Spacer()
            }
            // Splitting into two invididual VStacks, because LoginView needs
            // to move with Keyboard while `CopyrightLogos` should remain at
            // bottom.
            VStack {
                Spacer()
                CopyrightLogos()
                    .padding()
                    .ignoresSafeArea()
                    .background(
                        Color("BackgroundColor", bundle: .module)
                            .opacity(0.80)
                            .cornerRadius(12)
                    )
                    .padding()
            }.ignoresSafeArea(.keyboard)
        }.background(
            GeometryReader { geometry in
                LoginBackground()
                    .position(
                        // offset image horizontally on the phone for the face to be visible
                        x: geometry.size.width / 2 - (UIDevice.current.userInterfaceIdiom == .phone ? 60 : 0),
                        y: geometry.size.height / 2
                    )
            }.ignoresSafeArea(.keyboard, edges: .bottom)  // prevent resize when keyboard appears
        )
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            LoginScreen(userModel: LoginUserModel())
                .colorScheme(colorScheme)
        }
    }
}
