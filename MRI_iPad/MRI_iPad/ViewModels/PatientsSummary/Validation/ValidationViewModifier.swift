//
//  ValidationViewModifier.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 02.07.21.
//

import SwiftUI
import Foundation

struct ValidationViewModifier: ViewModifier {
    @State var latestValidation: Validation = .success
    let validationPublisher: ValidationPublisher
    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
            if !latestValidation.isSuccess {
                Text(latestValidation.getMessage)
                    .foregroundColor(Color.red)
                    .font(.caption)
            }
        }
        .onReceive(validationPublisher) { validation in
            self.latestValidation = validation
        }
        .padding(.vertical, latestValidation.isSuccess ? 10 : 5)
    }
}

extension View {
    func validation(_ validationPublisher: ValidationPublisher) -> some View {
        self.modifier(ValidationViewModifier(validationPublisher: validationPublisher))
    }
}
