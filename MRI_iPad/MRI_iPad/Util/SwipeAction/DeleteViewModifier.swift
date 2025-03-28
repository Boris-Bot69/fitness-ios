//
//  DeleteViewModifier.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 01.07.21.
//  Adapted from: https://stackoverflow.com/questions/64103113/deleting-rows-inside-lazyvstack-and-foreach-in-swiftui

import Foundation
import SwiftUI
import Combine

struct Delete: ViewModifier {
    let name: String
    let action: () -> Void
    
    @State var offset: CGSize = .zero
    @State var initialOffset: CGSize = .zero
    @State var contentWidth: CGFloat = 0.0
    @State var showAlert = false
   
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    ZStack {
                        Rectangle()
                            .foregroundColor(.red)
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.title2.bold())
                            .layoutPriority(-1)
                    }.frame(width: -offset.width)
                    .offset(x: geometry.size.width)
                    .onAppear {
                        contentWidth = geometry.size.width
                    }
                    .gesture(
                        TapGesture()
                            .onEnded {
                                showAlert = true
                            }
                    )
                }
            )
            .offset(x: offset.width, y: 0)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width + initialOffset.width <= 0 {
                            self.offset.width = gesture.translation.width + initialOffset.width
                        }
                    }
                    .onEnded { _ in
                        if offset.width < -halfDeletionDistance {
                            offset.width = -tappableDeletionWidth
                            initialOffset.width = -tappableDeletionWidth
                        } else {
                            offset = .zero
                            initialOffset = .zero
                        }
                    }
            )
            .animation(.interactiveSpring())
            .alert(isPresented: $showAlert) {
                deleteAlert(name: name)
            }
    }
    
    private func delete() {
        offset.width = -contentWidth
        action()
    }
    
    private func cancel() {
        offset = .zero
        initialOffset = .zero
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func deleteAlert(name: String) -> Alert {
        Alert(title: Text("Delete".localized),
              message: Text(name + " will be deleted permanently, continue?".localized),
              primaryButton: .destructive(Text("Delete".localized), action: {
                delete()
              }),
              secondaryButton: .default(Text("Cancel".localized), action: {
                cancel()
              }))
    }
    
    // MARK: Constants
    
    let deletionDistance = CGFloat(200)
    let halfDeletionDistance = CGFloat(50)
    let tappableDeletionWidth = CGFloat(100)
}

extension View {
    func onDelete(name: String, perform action: @escaping () -> Void) -> some View {
        self.modifier(Delete(name: name, action: action))
    }
}
