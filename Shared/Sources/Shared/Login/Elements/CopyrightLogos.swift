//
//  CopyrightLogos.swift
//  
//
//  Created by Jannis Mainczyk on 22.06.21.
//

import SwiftUI

struct CopyrightLogos: View {
    private static let bottomLogoHeight: CGFloat = 40.0

    var body: some View {
        HStack(spacing: 20) {
//            Image("TUMLogo", bundle: .module)
//                .scaleToFit(height: CopyrightLogos.bottomLogoHeight)
//            Image("ASELogo", bundle: .module)
//                .scaleToFit(height: CopyrightLogos.bottomLogoHeight)
            Image("MRIDepartment", bundle: .module)
                .scaleToFit(height: CopyrightLogos.bottomLogoHeight)
        }
    }
}

extension Image {
    /**
     Resize image in a single modifier, keeping it's aspect ratio.
     */
    func scaleToFit(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height, alignment: alignment)
   }
}

struct CopyrightLogos_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                ZStack {
                    Color("ContrastColor", bundle: .module)
                    CopyrightLogos()
                }.colorScheme(colorScheme)
            }
        }
    }
}
