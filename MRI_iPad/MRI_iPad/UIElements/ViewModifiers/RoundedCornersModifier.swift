//
//  RoundedCornersModifier.swift
//  DoctorsApp
//
//  Created by Patrick Witzigmann on 12.06.21.
//

import Foundation
import SwiftUI

///This View extension lets you round individual corner of a view with the following syntax  .cornerRadius(5, corners: [.topLeft, .bottomLeft])
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
