//
//  EditWorkoutIntensitySlider.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 11.06.21.
//

import SwiftUI

struct BorgScale {
    var value: Int?
    
    
    var description: String {
        switch value {
        case 6, 7:
            return NSLocalizedString("no exertion at all", comment: "BorgScale: 6-7")
        case 8:
            return NSLocalizedString("extremely light", comment: "BorgScale: 8")
        case 9, 10:
            return NSLocalizedString("very light", comment: "BorgScale: 9-10")
        case 11, 12:
            return NSLocalizedString("light", comment: "BorgScale: 11-12")
        case 13, 14:
            return NSLocalizedString("somewhat hard", comment: "BorgScale: 13-14")
        case 15, 16:
            return NSLocalizedString("hard", comment: "BorgScale: 15-16")
        case 17, 18:
            return NSLocalizedString("very hard", comment: "BorgScale: 17-18")
        case 19:
            return NSLocalizedString("extremely hard", comment: "BorgScale: 19")
        case 20:
            return NSLocalizedString("maximal exertion", comment: "BorgScale: 20")
        default:
            return NSLocalizedString("not set", comment: "BorgScale: <6 or >20")
        }
    }
}

struct EditWorkoutIntensitySlider: View {
    @Binding var intensity: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .bottom) {
                Text("Intensity").font(.headline)
                Text("\(intensity > 5 ? Int(intensity) : 0)")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Spacer()
                Text(BorgScale(value: Int(intensity)).description)
                    .font(.subheadline)
                    .foregroundColor(.FontLight)
            }
            Slider(
                value: $intensity,
                in: 5...20,
                step: 1,
                onEditingChanged: { editing in
                    if !editing {
                        print("Intensity: \(intensity)")
                    }
                }
            ) {
                Text("Intensity")
            }
        }
    }
}

struct EditWorkoutIntensitySlider_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(12) {
            EditWorkoutIntensitySlider(intensity: $0)
        }.padding()
    }
}
