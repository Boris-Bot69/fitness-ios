//
//  EditPatientViewModel.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 22.06.21.
//swiftlint:disable force_unwrapping

import SwiftUI
import Combine
import Foundation
import Shared
import HealthKit

class EditPatientViewModel: ObservableObject {
    var patient: PatientSummary?
    //Constants
    final let emailPattern = #"^\S+@\S+\.\S+$"#
    final let atLeastThreeChars = "[A-Za-z]{3}"
    final let formDateFormat = "dd.MM.yyyy"
    @Published var active = true
    //Patient Profile data input
    @Published var username: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var emailAddress: String = ""
    @Published var birthday: String = ""
    @Published var gender: Gender?
    @Published var weight: String?
    @Published var height: String?
    //Treatment data input
    @Published var selectedStudyGroup: StudyGroup?
    @Published var startDate: String = ""
    @Published var endDate: String = ""
    @Published var goal: String = ""
    @Published var comment: String?
    //Training zones data input
    @Published var trainingZones: [EditPatientTrainingZones] = [EditPatientTrainingZones()]
    @Published var showPatchProgressView = false
    var dismissFormPublisher = PassthroughSubject<Bool, Never>()
    var dismissForm = false {
        didSet {
            dismissFormPublisher.send(dismissForm)
        }
    }
    
    init(patient: PatientSummary? = nil) {
        if let profile = patient {
            self.patient = profile
            self.active = profile.active
            self.username = profile.username
            self.firstName = profile.firstName
            self.lastName = profile.lastName
            self.emailAddress = profile.email ?? ""
            self.birthday = profile.birthday.asDateString
            self.gender = profile.gender == nil ? nil : Gender(rawValue: profile.gender!)
            self.weight = profile.weight == nil ? "" : String(profile.weight.unsafelyUnwrapped)
            self.height = profile.height == nil ? "" : String(profile.height.unsafelyUnwrapped)
            self.startDate = profile.treatmentStarted.asDateString
            self.endDate = profile.treatmentFinished?.asDateString ?? ""
            self.goal = profile.treatmentGoal
            self.comment = profile.comment
            self.trainingZones = profile.trainingZoneIntervals.map { interval in
                EditPatientTrainingZones(
                    values: [String(interval.upper0Bound), String(interval.upper1Bound), String(interval.upper2Bound), String(interval.upper3Bound)],
                    workoutType: interval.workoutType,
                    unit: Unit(rawValue: interval.unit)
                )
            }
            studyGroupService.getStudyGroups()
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        print(completion)
                    },
                    receiveValue: { studyGroupsList in
                        if !profile.studyGroups.isEmpty {
                            self.selectedStudyGroup = studyGroupsList.first { $0.name == profile.studyGroups.last }
                        }
                    })
                .store(in: &cancellables)
            $active
                .sink(receiveValue: {
                    if !$0 {
                        self.endDate = Date().asDateString
                    }
                })
                .store(in: &cancellables)
        }
        trainingZones.forEach { zones in
            zones
                .trainingZonesValidator
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
            
            zones
                .objectWillChange
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }
    }
    
    //Patient Profile data validator
    lazy var usernameValidator: ValidationPublisher = {
        ValidationPublishers.combine(
            $username.notEmptyValidator("Username must not be empty".localized),
            $username.patternValidator(atLeastThreeChars, "Username must have at least 3 characters".localized)
        )
    }()
    lazy var firstNameValidator: ValidationPublisher = {
        $firstName.notEmptyValidator("First name must not be empty".localized)
    }()
    lazy var lastNameValidator: ValidationPublisher = {
        $lastName.notEmptyValidator("Last name must not be empty".localized)
    }()
    lazy var emailAddressValidator: ValidationPublisher = {
        ValidationPublishers.combine(
            $emailAddress.notEmptyValidator("Email address must not be empty".localized),
            $emailAddress.patternValidator(emailPattern, "Email address is not valid".localized)
        )
    }()
    lazy var birthdayValidator: ValidationPublisher = {
        ValidationPublishers.combine(
            $birthday.notEmptyValidator("Birthday must not be empty".localized),
            $birthday.dateValidator(formDateFormat, "Birthday must be in dd.mm.yyyy format".localized)
        )
    }()
    lazy var weightValidator: ValidationPublisher = {
        $weight.floatValidator("Weight must be a float".localized)
    }()
    lazy var heightValidator: ValidationPublisher = {
        $height.intValidator("Height must be a number".localized)
    }()
    //Treatment data validation
    lazy var startDateValidator: ValidationPublisher = {
        ValidationPublishers.combine(
            $startDate.notEmptyValidator("Start date must not be empty".localized),
            $startDate.dateValidator(formDateFormat, "Start date must be in dd.mm.yyyy format".localized)
        )
    }()
    lazy var endDateValidator: ValidationPublisher = {
        ValidationPublishers.combine(
            ValidationPublishers.combine(
                $endDate.notEmptyValidator("End date must not be empty"),
                $endDate.dateValidator(formDateFormat, "End date must be in dd.mm.yyyy format")
            ),
            $endDate.dateValidator(formDateFormat, isAfter: $startDate, "End date must not before start date".localized)
        )
    }()
    lazy var goalValidator: ValidationPublisher = {
        ValidationPublishers.combine(
            $goal.notEmptyValidator("Goal must not be empty".localized),
            $goal.patternValidator(atLeastThreeChars, "Goal must have at least 3 characters".localized)
        )
    }()
    lazy var commentValidator: ValidationPublisher = {
        $comment.patternValidator(atLeastThreeChars, "Comment must have at least 3 characters".localized)
    }()
    
    lazy var trainingZonesValidator: ValidationPublisher = {
        ValidationPublishers.combineAll(self.trainingZones.map { $0.trainingZonesValidator })
    }()
    
    //for enabling save button
    lazy var formValidator: ValidationPublisher = {
        var validator: ValidationPublisher
        validator = ValidationPublishers.combineAll(
        usernameValidator,
        firstNameValidator,
        lastNameValidator,
        emailAddressValidator,
        birthdayValidator,
        weightValidator
            .prepend(.success)
            .eraseToAnyPublisher(),
        heightValidator
            .prepend(.success)
            .eraseToAnyPublisher(),
        startDateValidator,
        endDateValidator,
        goalValidator,
        commentValidator
            .prepend(.success)
            .eraseToAnyPublisher()
        )
        if !self.trainingZones.isEmpty {
            validator = validator.append(trainingZonesValidator).eraseToAnyPublisher()
        }
        if patient != nil {
            return validator.prepend(.success).eraseToAnyPublisher()
        }
        return validator
    }()
    
    @Published var presentAlert = false
    @Published var showCredentials = false
    @Published var showStudyGroupPicker = false
    
    @Published var studyGroups: [StudyGroup] = []
    var trainerId: Int = 1 //will be changed after the trainerId persisted in keychain
    var password: String = ""
    var errorMessage: String = ""
    var errorHeader: String = "Error!".localized
    var successHeader: String = "Patient registered successfully!".localized
    let units = [Unit.bpm, Unit.kmh]
    let workoutTypes = [HKWorkoutActivityType.running, HKWorkoutActivityType.cycling]

    var cancellables: [AnyCancellable] = []
    
    /// Services necessary to fetch data from the api
    let accountService = AccountService()
    let studyGroupService = StudyGroupService()
    let patientService = PatientService()
    
    @Published var loading = false
    var disableSaveButton = true
    
    func addTrainingZones() {
        let zones = EditPatientTrainingZones()
        zones
            .objectWillChange
            .sink { _ in
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
        self.trainingZones.append(zones)
    }
    
    func removeTrainingZones(index: Int) {
        self.trainingZones.remove(at: index)
    }
}

extension EditPatientViewModel: CredentialsViewModel { }
