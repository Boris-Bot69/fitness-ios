//
//  UIWindow+TapGestureRecognizer.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 17.06.21.
//

import Foundation
import UIKit

/// Application will hide keyboard on tap gestures outside textfields.
///
/// Add this functionality to your app using the following modifier on your top-level View:
///
/// Usage:
///     `.onAppear(perform: UIApplication.shared.addTapGestureRecognizer)`
///
/// Example:
///     `ContentView().onAppear(perform: UIApplication.shared.addTapGestureRecognizer)`
///
/// Source:
///     https://www.dabblingbadger.com/blog/2020/11/5/dismissing-the-keyboard-in-swiftui
extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else {
            return
        }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        tapGesture.name = "MyTapGesture"
        window.addGestureRecognizer(tapGesture)
    }
}
