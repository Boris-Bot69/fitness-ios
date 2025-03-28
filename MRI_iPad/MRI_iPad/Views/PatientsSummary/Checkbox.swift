//
//  Checkbox.swift
//  DoctorsApp
//
//  Created by Jannis Mainczyk on 13.07.21.
//

import SwiftUI

struct Checkbox: View {
    var toggled: Bool
    var onTap: () -> Void

    var body: some View {
        Image(systemName: toggled ? "checkmark.square.fill" : "square")
            .font(.system(size: 25).weight(.regular))
            .foregroundColor(.DarkBlue)
            .onTapGesture {
                onTap()
            }
    }
}

struct Checkbox_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            HStack {
                Checkbox(toggled: false, onTap: {})
                    .previewLayout(PreviewLayout.fixed(width: 100, height: 50))
                Text(String("unchecked"))  // use `String` to prevent localization
            }
            HStack {
                Checkbox(toggled: true, onTap: {})
                Text(String("checked"))
            }
        }.frame(width: 200)
        .previewLayout(.fixed(width: 300, height: 80))
    }
}
