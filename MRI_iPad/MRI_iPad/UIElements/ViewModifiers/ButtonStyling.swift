//
//  ButtonStyling.swift
//  DoctorsApp
//
//  Created by Patrick Witzigmann on 13.06.21.
//

import SwiftUI

///The .buttonStyled() viewmodifier provides the standard Button styling
struct ButtonStyling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 11)
            .background(Color.DarkBlue)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

extension View {
    func buttonStyled() -> some View {
        self.modifier(ButtonStyling())
    }
}
