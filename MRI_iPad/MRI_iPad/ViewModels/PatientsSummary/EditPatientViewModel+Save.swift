//
//  EditPatientViewModel+Save.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 13.07.21.
//
//swiftlint:disable force_unwrapping

import Foundation
import Shared
import Combine

extension EditPatientViewModel: SaveButtonViewModel {
    func save() {
        if let patient = self.patient {
            self.showPatchProgressView = true
            patchAccount(patient: patient)
        } else {
            createAccount()
        }
    }
    
    func patchAccount(patient: PatientSummary) {
        Publishers.Zip4(
            createPatchAccountMediator(patient: patient)
                .flatMap { self.accountService.patchAccount($0) },
            createPatchPatientMediator(patient: patient)
                .flatMap { self.patientService.patchPatient($0) },
            createTrainingZones(patientId: patient.id)
                .flatMap { self.patientService.postTrainingZones($0) },
            createStudyGroupMember(patientId: patient.id)
                .flatMap { self.studyGroupService.postStudyGroupMember($0) }
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                self.dismissForm = true
            case .failure(let error):
                let errorMessage: String
                switch error {
                case .error4xx(let code):
                    errorMessage = "Error \(code), username or email already exists".localized
                default:
                    errorMessage = error.errorDescription ?? error.localizedDescription
                }
                self.errorMessage = errorMessage
                self.presentAlert = true
            }
            self.showPatchProgressView = false
        },
        receiveValue: { _ in })
        .store(in: &self.cancellables)
        
        if let delete = deleteTrainingZones(patient: patient) {
            delete
                .flatMap { self.patientService.deleteTrainingZones(id: $0) }
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.dismissForm = true
                    case .failure(let error):
                        let errorMessage: String
                        switch error {
                        case .error4xx(let code):
                            errorMessage = "Error \(code), username or email already exists".localized
                        default:
                            errorMessage = error.errorDescription ?? error.localizedDescription
                        }
                        self.errorMessage = errorMessage
                        self.presentAlert = true
                    }
                    self.showPatchProgressView = false
                },
                receiveValue: { _ in })
                .store(in: &self.cancellables)
        }
    }
    
    func createPatchAccountMediator(patient: PatientSummary) -> AnyPublisher<PatchAccountMediator, Never> {
        Just(PatchAccountMediator(
            id: patient.accountId,
            username: self.username == patient.username ? nil : self.username,
            email: self.emailAddress == patient.email ? nil : self.emailAddress,
            birthday: convertDateStringFormat(date: self.birthday),
            firstName: self.firstName,
            lastName: self.lastName,
            active: self.active
        )).eraseToAnyPublisher()
    }
    
    func createPatchPatientMediator(patient: PatientSummary) -> AnyPublisher<PatchPatientMediator, Never> {
        Just(PatchPatientMediator(
            id: patient.id,
            treatmentStarted: convertDateStringFormat(date: self.startDate),
            treatmentFinished: convertDateStringFormat(date: self.endDate),
            treatmentGoal: self.goal,
            height: self.height?.intValue,
            weight: self.weight?.floatValue,
            gender: self.gender?.rawValue,
            comment: self.comment == nil ? "" : self.comment
        )).eraseToAnyPublisher()
    }
    
    func createTrainingZones(patientId: Int) -> AnyPublisher<PostTrainingZonesMediator, Never> {
        Publishers.MergeMany( self.trainingZones.map {
            Just(PostTrainingZonesMediator(
                    patientId: patientId,
                    workoutType: Int($0.workoutType?.rawValue ?? 1000),
                    unit: $0.unit?.rawValue ?? "",
                    values: $0.values.map { Int($0) ?? -1 }
            ))
        })
        .eraseToAnyPublisher()
    }
    
    func deleteTrainingZones(patient: PatientSummary) -> AnyPublisher<Int, Never>? {
        let ids: [AnyPublisher<Int, Never>] = patient.trainingZoneIntervals.compactMap { previous in
            if !self.trainingZones.contains(where: { $0.workoutType?.rawValue == UInt(previous.workoutType) && $0.unit?.rawValue == previous.unit }) {
                print(previous.id)
                return Just(previous.id).eraseToAnyPublisher()
            } else {
                return nil
            }
        }
        if ids.isEmpty {
            return nil
        } else {
            return Publishers.MergeMany(ids).eraseToAnyPublisher()
        }
    }
    
    func createStudyGroupMember(patientId: Int) -> AnyPublisher<PostStudyGroupMemberMediator, Never> {
        Just(PostStudyGroupMemberMediator(
            self.selectedStudyGroup!.studyGroupId,
            patientId: patientId
        )).eraseToAnyPublisher()
    }
    
    
    func createAccount() {
        let birthday = convertDateStringFormat(date: birthday)
        let startDate = convertDateStringFormat(date: startDate)
        password = randomPassword()
        let endDate = convertDateStringFormat(date: endDate)
        let height = self.height?.intValue
        let weight = self.weight?.floatValue
        
        //execute post account request
        accountService.postAccount(
            PostAccountMediator(username, email: emailAddress, password: password, birthday: birthday, firstName: firstName, lastName: lastName)
        )
        .compactMap { $0.account } // map to int for account id
        .flatMap { [self] accountId in // chain request with post patient
            self.patientService.postPatient(
                PostPatientMediator(
                    accountId: accountId,
                    treatmentStarted: startDate,
                    treatmentFinished: endDate,
                    treatmentGoal: goal,
                    height: height,
                    weight: weight,
                    gender: gender?.rawValue,
                    comment: comment
                )
            )
        }
        .compactMap { $0.patientId } // map to int for patient id
        .flatMap { patientId in // simultaneously request post training zones and study group member
            Publishers.Zip(
                self.createStudyGroupMember(patientId: patientId)
                    .flatMap { self.studyGroupService.postStudyGroupMember($0) },
                self.createTrainingZones(patientId: patientId)
                    .flatMap { self.patientService.postTrainingZones($0) }
            )
        }
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                let errorMessage: String
                switch error {
                case .error4xx(let code):
                    errorMessage = "Error \(code), username or email already exists".localized
                default:
                    errorMessage = error.errorDescription ?? error.localizedDescription
                }
                self.errorMessage = errorMessage
                self.presentAlert = true
            }
        },
        receiveValue: { _ in
            self.showCredentials = true
        })
        .store(in: &self.cancellables)
    }
    
    private func randomPassword() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map { _ in letters.randomElement()! })
    }
    
    private func convertDateStringFormat(date: String) -> String {
        let serverDateFormatter = DateFormatter()
        serverDateFormatter.dateFormat = "yyyy-MM-dd"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        guard let dateFromString = formatter.date(from: date) else {
            return ""
        }
        return serverDateFormatter.string(from: dateFromString)
    }
}
