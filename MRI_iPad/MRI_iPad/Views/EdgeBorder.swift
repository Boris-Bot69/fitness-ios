//
//  EdgeBorder.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 25.06.21.
//

import SwiftUI

// Found on: https://stackoverflow.com/questions/58632188/swiftui-add-border-to-one-edge-of-an-image#58632759
struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var xValue: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var yValue: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var wValue: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var hValue: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: xValue, y: yValue, width: wValue, height: hValue)))
        }
        return path
    }
}
