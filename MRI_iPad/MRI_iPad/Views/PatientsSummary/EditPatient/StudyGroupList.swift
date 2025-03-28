//
//  SelectionList.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 03.07.21.
//

import SwiftUI
import Shared

protocol StudyGroupListViewModel: ObservableObject {
    var studyGroups: [StudyGroup] { get }
    var selectedStudyGroup: StudyGroup? { get set }
    func delete(_ studyGroup: StudyGroup)
}

struct StudyGroupList<V: StudyGroupListViewModel>: View {
    @ObservedObject var viewModel: V
    var body: some View {
        ScrollView {
            ZStack {
                if viewModel.selectedStudyGroup == nil {
                    Color.LightGrey.edgesIgnoringSafeArea(.all)
                }
                HStack {
                    Text("No Study Group")
                        .italic()
                        .padding(.horizontal, 15)
                    Spacer()
                }
                .frame(height: 45)
                .onTapGesture {
                    viewModel.selectedStudyGroup = nil
                }
            }
            ForEach(viewModel.studyGroups, id: \.self) { studyGroup in
                ZStack {
                    if studyGroup == viewModel.selectedStudyGroup {
                        Color.LightGrey.edgesIgnoringSafeArea(.all)
                    }
                    HStack {
                        Text(studyGroup.name).tag(studyGroup as StudyGroup?)
                            .padding(.horizontal, 15)
                        Spacer()
                    }
                }
                .frame(height: 45)
                .onDelete(name: studyGroup.name) {
                    viewModel.delete(studyGroup)
                }
                .onTapGesture {
                    viewModel.selectedStudyGroup = studyGroup
                }
            }
        }
        .font(.system(size: 20))
        .labelsHidden()
    }
}

class SelectionListDummyViewModel: StudyGroupListViewModel {
    var studyGroups: [StudyGroup] =
        [
            StudyGroup(name: "Marathon Training", studyGroupId: 1),
            StudyGroup(name: "Sprint Training", studyGroupId: 2)
        ]
    var selectedStudyGroup: StudyGroup?
    func delete(_ studyGroup: StudyGroup) {
    }
}

struct SelectionList_Previews: PreviewProvider {
    static var previews: some View {
        StudyGroupList(viewModel: SelectionListDummyViewModel())
            .frame(width: 400, height: 450, alignment: .center)
            .previewLayout(.sizeThatFits)
    }
}
