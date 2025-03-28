//
//  SwipeActionViewModifier.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 07.07.21.
//
//swiftlint:disable force_unwrapping function_body_length

import Foundation
import SwiftUI

struct SwipeActions<T: Action, U: Action>: ViewModifier {
    // MARK: Constants
    let minSwipeDistance = CGFloat(75)
    let tappableActionsWidth = CGFloat(100)
    
    var leading: T?
    var trailing: U?
    
    init(leading: T) {
        trailing = nil
        self.leading = leading
    }
    
    init(trailing: U) {
        self.trailing = trailing
        self.leading = nil
    }
    
    init(leading: T, trailing: U) {
        self.leading = leading
        self.trailing = trailing
    }
    
    @State var leadingAlert = false
    @State var trailingAlert = false
    @State var leadingAlertMessage: String = ""
    @State var trailingAlertMessage: String = ""
    @State var offset: CGSize = .zero
    @State var initialOffset: CGSize = .zero
    @State var contentWidth: CGFloat = 0.0
    
    //frame size increases with travelled swipe drag gesture,
    //translate the view as far left and as far right as possible
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    leading
                        .frame(width: offset.width)
                        .offset(x: -geometry.frame(in: .global).minX)
                        .onAppear {
                            contentWidth = geometry.size.width
                        }
                        .onTapGesture {
                            switch leading?.actionType {
                            case .delete(let alert):
                                leadingAlertMessage = alert
                                leadingAlert = true
                            default:
                                leading?.action()
                                offset = .zero
                                initialOffset = .zero
                            }
                        }
                        .alert(isPresented: $leadingAlert) {
                            deleteAlert(name: leadingAlertMessage, action: leading!.action)
                        }
                    trailing
                        .frame(width: -offset.width)
                        .offset(x: geometry.frame(in: .global).maxX + -offset.width)
                        .onAppear {
                            contentWidth = geometry.size.width
                        }
                        .onTapGesture {
                            switch trailing?.actionType {
                            case .delete(let alert):
                                trailingAlertMessage = alert
                                trailingAlert = true
                            default:
                                trailing?.action()
                                offset = .zero
                                initialOffset = .zero
                            }
                        }
                        .alert(isPresented: $trailingAlert) {
                            deleteAlert(name: trailingAlertMessage, action: trailing!.action)
                        }
                }
            )
            .offset(x: offset.width, y: 0)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        //prevent drag animation when it is not specified
                        if (trailing != nil && gesture.translation.width + initialOffset.width <= 0)
                            || (leading != nil && gesture.translation.width + initialOffset.width >= 0) {
                            //programmatically change the state variable
                            self.offset.width = gesture.translation.width + initialOffset.width
                        }
                    }
                    .onEnded { _ in
                        if trailing != nil && offset.width < -minSwipeDistance {
                            //for swipe left stop at width -100 relative to its offset
                            offset.width = -tappableActionsWidth
                            initialOffset.width = -tappableActionsWidth
                        } else if leading != nil && offset.width > minSwipeDistance {
                            //for swipe right stop at width 100
                            offset.width = tappableActionsWidth
                            initialOffset.width = tappableActionsWidth
                        } else {
                            offset = .zero
                            initialOffset = .zero
                        }
                    }
            )
            .animation(.interactiveSpring())
    }
    
    private func delete(action: () -> Void) {
        offset.width = -contentWidth
        action()
    }
    
    private func defaultAction() {
        offset = .zero
        initialOffset = .zero
    }
    
    
    private func deleteAlert(name: String, action: @escaping () -> Void) -> Alert {
        Alert(title: Text("Delete".localized),
              message: Text(name + " will be deleted permanently, continue?"),
              primaryButton: .destructive(Text("Delete".localized), action: {
                delete(action: action)
              }),
              secondaryButton: .default(Text("Cancel".localized), action: {
                defaultAction()
              }))
    }
}

extension View {
    func swipeActions<T, U>(leading: T) -> some View where T: Action, U: Action {
        self.modifier(SwipeActions<T, U>(leading: leading))
    }
    func swipeActions<T, U>(trailing: U) -> some View where T: Action, U: Action {
        self.modifier(SwipeActions<T, U>(trailing: trailing))
    }
    func swipeActions<T, U>(leading: T, trailing: U) -> some View where T: Action, U: Action {
        self.modifier(SwipeActions<T, U>(leading: leading, trailing: trailing))
    }
}
