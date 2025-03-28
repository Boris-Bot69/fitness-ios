//
//  LoginDoctorModel.swift
//  DoctorsApp
//
//  Created by Christopher Schütz on 13.07.21.
//

import Shared
import Foundation

class LoginDoctorModel: LoginUserModel {
    @Published var trainerId: Int?
    
    override func readCredentialsFromKeychain() {
        super.readCredentialsFromKeychain()
        self.trainerId = Int(KeychainService.read(key: "trainerId") ?? "")
    }
    
    override func loginCallback(_ loginResponse: LoginMediator) {
        super.loginCallback(loginResponse)
        
        guard let trainerId = loginResponse.trainerId else {
            print("No tainerId returned in login response!")
            self.logout()
            return
        }
        
        self.trainerId = trainerId
        KeychainService.save(key: "trainerId", value: String(trainerId))
    }
    
    override func logout() {
        super.logout()
        self.trainerId = nil
        KeychainService.delete(key: "trainerId")
    }
}
