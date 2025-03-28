//
//  EditAction.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 07.07.21.
//

import SwiftUI

protocol Action: View {
    var actionType: ActionType { get }
    var action: () -> Void { get }
}

struct EditAction: Action {
    var actionType: ActionType = .edit
    var action: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.DarkBlue)
            Image(systemName: "square.and.pencil")
                .resizable()
                .frame(width: 25, height: 25, alignment: .center)
                .foregroundColor(.white)
                .font(.title2.bold())
                .layoutPriority(-1)
        }
    }
}

struct EditAction_Previews: PreviewProvider {
    static var previews: some View {
        EditAction {
        }.frame(width: 100, height: 70, alignment: .center)
    }
}
