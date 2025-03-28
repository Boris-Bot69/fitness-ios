//
//  EditPatientViewModel+StudyGroupPicker.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 06.07.21.
//

import Foundation
import Shared
import Combine

extension EditPatientViewModel: StudyGroupPickerViewModel {
    // executes request to get study groups list
    func getStudyGroups( _ id: Int? = nil) {
        studyGroupService.getStudyGroups()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    print(completion)
                },
                receiveValue: { studyGroupsList in
                    print(studyGroupsList)
                    self.studyGroups = studyGroupsList
                    if let studyGroupId = id {
                        self.selectedStudyGroup = self.studyGroups.first { $0.studyGroupId == studyGroupId }
                    }
                })
            .store(in: &cancellables)
    }
    
    // add new study group
    func add(name: String) {
        self.loading = true
        var id = -1
        //executes post study group
        studyGroupService.postStudyGroup(PostStudyGroupMediator(name))
            .compactMap { // map to int for study group id
                id = $0.studyGroup
                return $0.studyGroup
            }
            .flatMap { studyGroup in // chain request with post study group trainer
                self.studyGroupService.postStudyGroupTrainer(PostStudyGroupTrainerMediator(studyGroup, trainerId: self.trainerId))
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        self.errorMessage = "Fail to create study group!".localized
                        self.presentAlert = true
                    }
                    self.loading = false
                },
                receiveValue: { studyGroup in
                    print(studyGroup)
                    self.getStudyGroups(id == -1 ? nil : id)
                })
            .store(in: &self.cancellables)
    }
    
    func delete(_ studyGroup: StudyGroup) {
        //execute delete study group request
        self.studyGroupService.deleteStudyGroup(id: studyGroup.studyGroupId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    self.errorMessage = "Fail to remove study group!".localized
                    self.presentAlert = true
                    self.getStudyGroups()
                case .finished:
                    //delete study group from the list
                    self.studyGroups.removeAll { $0.studyGroupId == studyGroup.studyGroupId }
                    //remove if study group is selected
                    if self.selectedStudyGroup?.studyGroupId == studyGroup.studyGroupId {
                        self.selectedStudyGroup = nil
                    }
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
