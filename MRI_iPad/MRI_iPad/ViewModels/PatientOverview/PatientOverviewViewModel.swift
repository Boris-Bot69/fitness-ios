//
//  PatientOverviewViewModel.swift
//  DoctorsApp
//
//  Created by Benedikt Strobel on 17.07.21.
//

import Foundation
import Shared
import Combine

var cancellables: [AnyCancellable] = []

enum TrainigsplanUploadResult {
    case successful
    case failed
}

class PatientOverviewViewModel: ObservableObject {
    @Published var showAlert = false
    @Published var showSuccessTrainingsplanUploadAlert = false
    @Published var showFailureTrainingsplanUploadAlert = false
    
    func uploadTrainingPlan(patientId: Int, withUrls urls: [URL]) {
        showAlert = false
        showSuccessTrainingsplanUploadAlert = false
        showFailureTrainingsplanUploadAlert = false
        guard !urls.isEmpty else {
            print("********* Urls are empty")
            showFailureTrainingsplanUploadAlert = true
            showAlert = true
            return
        }
        let trainingPlanFileUrl = urls[0]
        
        var trainingPlanAsBase64: String?
        do {
            // requesting access is necessary to be able to read files stored in iPad Files App
            if trainingPlanFileUrl.startAccessingSecurityScopedResource() {
                let trainingPlanData = try Data(contentsOf: trainingPlanFileUrl)
                trainingPlanAsBase64 = trainingPlanData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                trainingPlanFileUrl.stopAccessingSecurityScopedResource()
            }
        } catch {
            print(error.localizedDescription)
        }
        
        guard let trainingPlanAsBase64 = trainingPlanAsBase64 else {
            print("********** Training Plan not parsed to String correctly")
            showFailureTrainingsplanUploadAlert = true
            showAlert = true
            return
        }
        
        let planningService = PlanningService()
        let trainingPlanPayload = TrainingPlanPostMediator(
            patientId: patientId,
            xlsxBase64: trainingPlanAsBase64
        )
        
        planningService.uploadTrainingPlan(trainingPlanPayload)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        print("Failure in uploading training plan")
                        self.showFailureTrainingsplanUploadAlert = true
                        self.showAlert = true
                    }
                },
                receiveValue: { trainingPlanResponseMediator in
                    print("Uploaded Training plan!\n Response: \(trainingPlanResponseMediator)")
                    self.showSuccessTrainingsplanUploadAlert = true
                    self.showAlert = true
                })
            .store(in: &cancellables)
    }
}
