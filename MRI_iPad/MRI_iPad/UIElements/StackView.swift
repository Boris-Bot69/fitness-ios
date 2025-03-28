//
//  StackView.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 04.06.21.
//
import SwiftUI

// Reusable View to display a view with a heading
struct StackView<Content: View>: View {
    let content: Content
    let label: String

    init(label: String, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.label = label
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .foregroundColor(.FontLight)
            
            content
                .foregroundColor(.FontPrimary)
                .font(.headline)
        }
        .padding()
    }
}
