//
//  PatientSummaryViewModel.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 30.05.21.
//swiftlint:disable force_unwrapping force_try force_cast

import Foundation
import Combine
import SwiftUI
import Shared

class PatientsSummaryViewModel: ObservableObject, SortableHeaderViewModel {
    var patientsArrayFromServer: [PatientSummary] = []
    @Published var patients: [PatientSummary] = []
    @Published var sortStates: [SortState]
    @Published var loadingState: LoadingState = .notStarted
    @Published var selectedPatients: [PatientSummary] = []
    @Published var selectedEndDate: Date?
    @Published var selectedStartDate: Date?
    @Published var receivingExportFiles = false
    private var searchPatientsString = ""
    var selectedEditPatient: PatientSummary?
    
    private var cancellables: [AnyCancellable] = []
    
    private var filesToExport: [XlsxDocument] = []
    
    let patientService: PatientService
    let accountService: AccountService
    
    init() {
        accountService = AccountService()
        patientService = PatientService()
        sortStates = Array(repeating: .none, count: 11)
        loadPatientSummaries()
    }
    
    //SortableHeaderViewModel implementation
    func sort(descriptor: @escaping (PatientSummary, PatientSummary) -> Bool, ascending: Bool) {
        //ugly because using objc but needed because swift sort is not stable
        let sorted = (patients as NSArray).sortedArray(options: .stable) {
            let lhs = $0 as! PatientSummary
            let rhs = $1 as! PatientSummary
            let descriptor = ascending ? descriptor(lhs, rhs) : descriptor(rhs, lhs)
            if lhs == rhs {
                return .orderedSame
            } else if descriptor {
                return .orderedAscending
            } else {
                return .orderedDescending
            }
        }
        patients = sorted as! [PatientSummary]
    }
    
    ///Executes the patients serach in the SearchBar. It enables searching for lastname, firstname, fullname, birthday, treatment started, treatment finished, studygroup and active / inactive patient. It can be searched for all parameters individually or in any combination. Different searchparameters however need to be separated by a "," or ";".
    func searchPatients(searchString: String) {
        //Separated the different search parameters and removes whitespaces
        let separators = CharacterSet(charactersIn: ",;")
        let searchParametersArray = searchString.components(separatedBy: separators)
        let cleanedSearchParametersArray = searchParametersArray.map { $0.removeAllWhitespaces() }.filter { !$0.isEmpty }
        
        //Filtering of patients
        var filteredPatients: [PatientSummary] = patientsArrayFromServer
        for parameter in cleanedSearchParametersArray {
            //
            let activeOrInactiveSearchedState = isActiveInactive(for: parameter)
            if activeOrInactiveSearchedState == .active {
                if !parameterExistsInNameOrStudyGroup(parameter: parameter) {
                    filteredPatients = filteredPatients.filter { $0.active }
                    continue
                }
            }
            if activeOrInactiveSearchedState == .inactive {
                if !parameterExistsInNameOrStudyGroup(parameter: parameter) {
                    filteredPatients = filteredPatients.filter { !$0.active }
                    continue
                }
            }
            
            //Processes search parameter for all variables except active / inactive
            filteredPatients =
                filteredPatients.filter { $0.birthday.asDateString.contains(parameter) }
                + filteredPatients.filter { $0.treatmentStarted.asDateString.contains(parameter) }
                + filteredPatients.filter { $0.treatmentFinished.asDateString.contains(parameter) }
                + filteredPatients.filter {
                    $0.studyGroups.isEmpty
                        ? false
                        : $0.studyGroups[0].lowercased().removeAllWhitespaces().contains(parameter.lowercased())
                }
                + filteredPatients.filter {
                    ($0.firstName+$0.lastName).lowercased().contains(parameter.lowercased())
                        || ($0.lastName+$0.firstName).lowercased().contains(parameter.lowercased())
                }
        }
        
        self.patients = filteredPatients.uniqued()
        
        func isActiveInactive(for string: String) -> ActiveInactiveSearchState {
            ///Here the keywords for active and inactive can be specified
            let activeKeywordsEnglish = ["active", "open"]
            let activeKeywordsGerman = ["aktiv", "offen"]
            let inactiveKeywordsEnglish = ["inactive", "closed"]
            let inactiveKeywordsGerman = ["inaktive", "abgeschlossen", "beendet", "abgelaufen"]
            
            let activeKeywordsCombined = activeKeywordsEnglish + activeKeywordsGerman
            let inactiveKeywordsCombined = inactiveKeywordsEnglish + inactiveKeywordsGerman
            
            for keyword in activeKeywordsCombined where keyword.contains(string.lowercased()) { return .active }
            for keyword in inactiveKeywordsCombined where keyword.contains(string.lowercased()) { return .inactive }
            return .notDefined
        }
        enum ActiveInactiveSearchState {
            case active
            case inactive
            case notDefined
        }
        
        func parameterExistsInNameOrStudyGroup(parameter: String) -> Bool {
            let filteredPatientsArr =
                filteredPatients.filter {
                    $0.studyGroups.isEmpty
                        ? false
                        : $0.studyGroups[0].lowercased().removeAllWhitespaces().contains(parameter.lowercased())
                }
                + filteredPatients.filter {
                    ($0.firstName+$0.lastName).lowercased().contains(parameter.lowercased()) ||
                        ($0.lastName+$0.firstName).lowercased().contains(parameter.lowercased())
                }
            return !filteredPatientsArr.isEmpty
        }
    }
    
    func setSearchPatientsString(_ searchPatientsString: String) {
        self.searchPatientsString = searchPatientsString
    }
    
    
    func reset() {
        for index in sortStates.indices {
            sortStates[index] = .none
        }
    }
    
    func loadPatientSummaries() {
        loadingState = .loading
        patientService.getSummariesOfPatients(start: self.selectedStartDate, end: self.selectedEndDate)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        self.loadingState = .loadingFailed
                        self.patients = []
                    }
                },
                receiveValue: { patientsSummaries in
                    self.patients = patientsSummaries
                    self.patientsArrayFromServer = patientsSummaries
                    self.loadingState = .loadedSuccessfully
                    self.searchPatients(searchString: self.searchPatientsString)
                })
            .store(in: &cancellables)
    }
    
    func toggleAllPatients() {
        if selectedPatients.count == patients.count {
            selectedPatients.removeAll()
        } else {
            selectedPatients.removeAll()
            selectedPatients.append(contentsOf: patients)
        }
    }
    
    func togglePatient(patientId: Int) {
        if selectedPatients.contains(where: { $0.id == patientId }) {
            selectedPatients.removeAll(where: { $0.id == patientId })
        } else {
            selectedPatients.append(patients.first(where: { $0.id == patientId })!)
        }
    }
    
    func loadLastSevenDays() {
        self.selectedStartDate = Foundation.Calendar.current.date(byAdding: .day, value: -7, to: Date())
        self.selectedEndDate = Date()
        loadPatientSummaries()
    }
    
    func resetTimeRange() {
        self.selectedStartDate = nil
        self.selectedEndDate = nil
    }
    
    func export() {
        let patientIds = self.selectedPatients.map { $0.id }
        receivingExportFiles = true
        patientService.getPatientsExport(from: self.selectedStartDate,
                                         to: self.selectedEndDate,
                                         ids: patientIds)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    print(completion)
                    self.receivingExportFiles = false
                },
                receiveValue: { patientExports in
                    patientExports.forEach { patientExport in
                        let string = patientExport.overview
                        let patient = self.patients.first(where: { $0.id == patientExport.patientId })
                        let fileName = "\(patient?.lastName ?? "lastName"), \(patient?.firstName ?? "firstName")"
                        if let base64Decoded = Data(base64Encoded: string, options: NSData.Base64DecodingOptions(rawValue: 0)) {
                            let documentDirectoryUrl = try! FileManager.default.url(
                                for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
                            )
                            let fileUrl = documentDirectoryUrl.appendingPathComponent(fileName).appendingPathExtension("xlsx")
                            self.filesToExport.append(XlsxDocument(byteData: base64Decoded, fileName: fileName + ".xlsx"))
                            try! base64Decoded.write(to: fileUrl)
                        }
                        self.selectedPatients.removeAll()
                    }
                })
            .store(in: &cancellables)
    }
    
    func delete(patient: PatientSummary) {
        self.accountService.deleteAccount(id: patient.accountId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("fail")
                    self.loadPatientSummaries()
                case .finished:
                    self.patients.removeAll { $0.accountId == patient.accountId }
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func getAndEmptyFilesToExport() -> [XlsxDocument] {
        let cache = filesToExport
        filesToExport.removeAll()
        return cache
    }
}

class MockPatientsSummaryViewModel: PatientsSummaryViewModel {
    override init() {
        super.init()
        let mock = MockModel()
        mock.loadPatientsSummaries()
        self.patients = mock.patientsSummaries!
        self.loadingState = .loadedSuccessfully
    }

    override func loadPatientSummaries() {}
}
