//
//  ActiveToggleStyle.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 07.07.21.
//

import Foundation
import SwiftUI

struct ActiveToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Rectangle()
                .foregroundColor(configuration.isOn ? .green : .gray)
                .frame(width: 51, height: 31, alignment: .center)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(.all, 3)
                        .overlay(
                            GeometryReader { _ in
                                Path { path in
                                    if !configuration.isOn {
                                        path.addRoundedRect(
                                            in: CGRect(x: 20, y: 10, width: 10.5, height: 10.5),
                                            cornerSize: CGSize(width: 7.5, height: 7.5),
                                            style: .circular,
                                            transform: .identity
                                        )
                                    } else {
                                        path.move(to: CGPoint(x: 51 / 2, y: 10))
                                        path.addLine(to: CGPoint(x: 51 / 2, y: 31 - 10))
                                    }
                                }.stroke(configuration.isOn ? Color.green : Color.gray, lineWidth: 2)
                            }
                        )
                        .offset(x: configuration.isOn ? 11 : -11, y: 0)
                        .animation(Animation.linear(duration: 0.1))
                )
                .cornerRadius(20)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
