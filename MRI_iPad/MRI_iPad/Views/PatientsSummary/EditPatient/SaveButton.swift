//
//  SaveButton.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 22.06.21.
//

import SwiftUI

protocol SaveButtonViewModel: ObservableObject {
    /// Indicates if the save button should be disabled
    var disableSaveButton: Bool { get set }
    /// Indicates if the save button progress indicator should be shown
    
    /// The action that should be performed by the save button
    func save()
}
// MARK: - SaveButton
/// Button that is used to save the edits made to a model conforming to `SaveButtonViewModel`
struct SaveButton<M: SaveButtonViewModel>: View {
    /// The `SaveButtonViewModel` that manages the content of the view
    @ObservedObject var viewModel: M
    
    /// Callback that is used to notify about the success of saving the element in the viewModel
    @State var onSuccess: (() -> Void)?
    /// Keeps a reference to the subscription that subscribes to the save transaction call in the Model

    var body: some View {
        Button(action: save) {
            Text("Save")
                .bold()
        }.disabled(viewModel.disableSaveButton)
    }


    /// Saves the element using the view model
    private func save() {
        viewModel.save()
        onSuccess?()
    }
}
