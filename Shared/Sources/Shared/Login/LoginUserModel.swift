//
//  LoginUserModel.swift
//  
//
//  Created by Christopher Schütz on 27.05.21.
//

import Foundation
import Combine

// MARK: - LoginUserModel
open class LoginUserModel: ObservableObject {
    @Published public var username: String
    @Published public var token: String?
    @Published public var errorMessage: String?
    
    public var cancellables: [AnyCancellable] = []

    public var bearerToken: String? {
        token.map { "Bearer \($0)" }
    }

    public var accountService = AccountService()

    public init(_ username: String = "", token: String? = nil) {
        self.username = username
        if let token = token {
            self.setToken(token, saveToKeychain: false)
        } else {
            readCredentialsFromKeychain()
        }
    }

    /// Authenticate with server using `username` and `password`
    public func login(_ username: String, password: String) {
        print("Login was clicked! (\(username):\(password))")
        self.username = username
        self.errorMessage = ""  // reset error messages of previous login attempts

        accountService.auth(username, password)
            .receive(on: RunLoop.main)  // Main Thread
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    switch error {
                    case .unauthorized:
                        self.errorMessage = "Wrong username or password"
                    default:
                        self.errorMessage = "Error during login"
                    }
                    print(self.errorMessage ?? "Unknown error during login")
                }
            },
            receiveValue: { loginResponse in
                self.loginCallback(loginResponse)
            })
            .store(in: &self.cancellables)
    }

    /// Delete token from memory and keychain
    open func logout() {
        DispatchQueue.main.async {
            self.token = nil
        }
        KeychainService.delete(key: "token")
    }

    open func loginCallback(_ loginResponse: LoginMediator) {
        self.setToken(loginResponse.token, saveToKeychain: true)
    }

    func setToken(_ token: String, saveToKeychain: Bool = true) {
        self.token = token
        RestfulManager.accessToken = token
        if saveToKeychain {
            KeychainService.save(key: "username", value: self.username)
            KeychainService.save(key: "token", value: token)
        }
    }

    open func readCredentialsFromKeychain() {
        guard let lastUsername = KeychainService.read(key: "username") else {
            print("No username found in keychain! Are you logging in for the first time?")
            return
        }
        self.username = lastUsername

        guard let lastToken = KeychainService.read(key: "token") else {
            print("No token for '\(self.username)' found in keychain! Are you logging in for the first time?")
            return
        }
        
        self.setToken(lastToken, saveToKeychain: false)
        self.checkTokenValidity()
    }
    
    private func checkTokenValidity() {
        // test if token is valid otherwise logout
        self.accountService.verifyToken()
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    self.logout()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
