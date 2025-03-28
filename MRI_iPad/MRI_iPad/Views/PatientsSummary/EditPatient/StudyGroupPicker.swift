//
//  StudyGroupPicker.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 01.07.21.
//

import Foundation
import SwiftUI
import Shared

protocol StudyGroupPickerViewModel: StudyGroupListViewModel, AddStudyGroupViewModel {
    var showStudyGroupPicker: Bool { get set }
    func getStudyGroups(_ id: Int?)
}

struct StudyGroupPicker<V: StudyGroupPickerViewModel>: View {
    @ObservedObject var viewModel: V
    
    var body: some View {
        ZStack {
            if viewModel.showStudyGroupPicker {
                Color.gray.opacity(0.4).edgesIgnoringSafeArea(.all)
                NavigationView {
                    VStack {
                        StudyGroupList(viewModel: viewModel)
                            .frame(height: 300)
                        
                        AddStudyGroup(viewModel: viewModel)
                            .frame(height: 80)
                    }
                    .navigationBarTitle(Text("Select Study Group".localized), displayMode: .inline)
                    .navigationBarItems(trailing: closeButton)
                }
                .frame(width: 400, height: 450, alignment: .center)
                .background(Color.primary.colorInvert())
                .cornerRadius(15)
                .onAppear {
                    viewModel.getStudyGroups(nil)
                }
            }
        }
    }
    
    var closeButton: some View {
        Button("Close".localized) {
            viewModel.showStudyGroupPicker = false
        }
    }
}

class DummyStudyGroupPickerViewModel: StudyGroupPickerViewModel {
    var loading = false
    var showStudyGroupPicker = true
    var studyGroups: [StudyGroup] =
        [
            StudyGroup(name: "Marathon Training", studyGroupId: 1),
            StudyGroup(name: "Sprint Training", studyGroupId: 2)
        ]
    var selectedStudyGroup: StudyGroup?
    func getStudyGroups(_ id: Int? = nil) {
    }
    func delete(_ studyGroup: StudyGroup) {
    }
    
    func add(name: String) {
    }
}

struct StudyGroupPicker_Previews: PreviewProvider {
    static var previews: some View {
        StudyGroupPicker(viewModel: DummyStudyGroupPickerViewModel())
    }
}
