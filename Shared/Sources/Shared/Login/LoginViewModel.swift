//
//  LoginViewModel.swift
//  
//
//  Created by Christopher Schütz on 27.05.21.
//

import Foundation

public class LoginViewModel: ObservableObject {
    @Published public var username: String = ""
    @Published public var password: String = ""

    private weak var model: LoginUserModel?

    public init(_ model: LoginUserModel) {
        self.model = model
        username = model.username
    }

    public var errorMessage: String {
        model?.errorMessage ?? ""
    }

    public func login() {
        model?.login(username, password: password)
    }

    public func logout() {
        model?.logout()
    }
}
