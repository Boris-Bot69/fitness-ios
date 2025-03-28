//
//  LoginPatientModel.swift
//  tumsm
//
//  Created by Christopher Schütz on 13.07.21.
//

import Shared
import Combine
import Foundation

class LoginPatientModel: LoginUserModel {
    @Published var patientId: Int?
    @Published var patientInfo: GetPatientMediator?
    
    let patientService = PatientService()
    
    override func readCredentialsFromKeychain() {
        super.readCredentialsFromKeychain()
        self.patientId = Int(KeychainService.read(key: "patientId") ?? "")
    }
    
    override func loginCallback(_ loginResponse: LoginMediator) {
        super.loginCallback(loginResponse)
        
        guard let patientId = loginResponse.patientId else {
            print("No patientId returned in login response!")
            self.logout()
            return
        }
        
        self.patientId = patientId
        KeychainService.save(key: "patientId", value: String(patientId))
    }
    
    func getPatientInfo(patientId: Int) {
        patientService.getPatient(identifier: patientId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error retrieving Patient Info")
                        print(error.localizedDescription)
                        self.logout()
                    }
                },
                receiveValue: { patientMediator in
                    self.patientInfo = patientMediator
                }
            )
            .store(in: &self.cancellables)
    }
    
    override func logout() {
        super.logout()
        self.patientId = nil
        KeychainService.delete(key: "patientId")
    }
}
