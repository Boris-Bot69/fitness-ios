//
//  WorkoutCommentEdit.swift
//  tumsm
//
//  Created by Jannis Mainczyk on 01.06.21.
//

import SwiftUI

struct EditWorkoutComment: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .bottom) {
                Text("Comment").font(.headline)
                Spacer()
                Text("\(200 - text.count) characters remaining")
                    .font(.subheadline)
                    .foregroundColor(.FontLight)
            }
            TextEditor(text: $text)
                .frame(minHeight: 40, idealHeight: 120, maxHeight: 200)
                .background(
                    Color.Textfield
                        .cornerRadius(6.0)
                )
                .multilineTextAlignment(.leading)
                .keyboardType(.alphabet)  // hide emoji-picker
            Spacer()
        }
    }
}

struct EditWorkoutComment_Previews: PreviewProvider {
    @State var text: String = "Großartiges Workout!"
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            StatefulPreviewWrapper("Großartiges Workout") { EditWorkoutComment(text: $0) }
                .padding()
                .background(
                    Color("BackgroundColor")
                        .ignoresSafeArea()
                )
                .colorScheme(colorScheme)
            Spacer()
        }
    }
}
