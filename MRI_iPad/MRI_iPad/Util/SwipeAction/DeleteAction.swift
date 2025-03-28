//
//  DeleteAction.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 07.07.21.
//

import SwiftUI

struct DeleteAction: Action {
    var actionType: ActionType
    var action: () -> Void
    
    init(alert: String, action: @escaping () -> Void) {
        self.actionType = .delete(alert: alert)
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.red)
            Image(systemName: "trash")
                .foregroundColor(.white)
                .font(.title2.bold())
                .layoutPriority(-1)
        }
    }
}

struct DeleteAction_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAction(alert: "") {
        }.frame(width: 100, height: 70, alignment: .center)
    }
}
