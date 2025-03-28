//
//  View.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 25.06.21.
//

import SwiftUI

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
