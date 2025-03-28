//
//  AddStudyGroup.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 02.07.21.
//

import SwiftUI


protocol AddStudyGroupViewModel: ObservableObject {
    var loading: Bool { get }
    /// The action that should be performed to add study group
    func add(name: String)
}

struct AddStudyGroup<V: AddStudyGroupViewModel>: View {
    @ObservedObject var viewModel: V
    @State var disableAddButton = true
    @State var name = ""
    
    var body: some View {
        ZStack {
            HStack {
                TextField("Name".localized, text: $name)
                    .frame(height: 42)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 12)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    .padding(.leading, 15)
                    .font(.system(size: 20))
                Spacer()
                Button("Add".localized) {
                    viewModel.add(name: name)
                    name = ""
                }
                .buttonStyled()
                .font(.system(size: 20))
                .disabled(name.isEmpty && name.count <= 3)
                .padding(.horizontal, 15)
            }
            if viewModel.loading {
                Color(.white).opacity(1.0)
                    .edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
            }
        }
    }
}

class DummyAddViewModel: AddStudyGroupViewModel {
    var loading = false
    var showAddStudyGroup = true
    func add(name: String) {
    }
}

struct AddStudyGroup_Previews: PreviewProvider {
    static var previews: some View {
        AddStudyGroup(viewModel: DummyAddViewModel())
            .frame(width: 450, height: 100, alignment: .center)
            .previewLayout(.sizeThatFits)
    }
}
