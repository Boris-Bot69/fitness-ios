//
//  LoginBackgroundView.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 16.05.21.
//

import SwiftUI

public struct LoginBackground: View {
    public var body: some View {
        ZStack {
            Image("LoginBackgroundImage", bundle: .module)
                .resizable()
                .scaledToFill()
            Color.black.opacity(0.1)
        }.ignoresSafeArea(.all, edges: .all)
    }
}

struct LoginBackground_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            LoginBackground()
                .colorScheme(colorScheme)
        }
    }
}
