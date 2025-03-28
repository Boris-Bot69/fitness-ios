//
//  AccountService.swift
//  
//
//  Created by Daniel Nugraha on 22.06.21.
//

import Combine
import Foundation

// MARK: AccountService
/// Service class for sending requests to account endpoints
public class AccountService: BaseService {
    /// initialize AccountService with `/account` prefix
    override public init() {
        super.init()
        self.prefixPath = "/account"
    }

    // MARK: POST /account/auth
    /// publishes a POST request with `username` and `password` in the body
    /// - Parameters
    ///     - username: username of patient or trainer account
    ///     - password: password for patient or trainer account
    public func auth(_ username: String, _ password: String) -> AnyPublisher<LoginMediator, ServiceError> {
        RestfulManager.postElement(
            ["username": username, "password": password],
            authorization: false,
            on: (self.baseUrl + "/auth")
        )
    }
    
    // MARK: POST /account
    /// publishes a POST request with a postAccountMediator payload in the body
    /// - Parameters
    ///     - postAccount: PostAccountMediator to be sent in the body
    public func postAccount(
        _ postAccount: PostAccountMediator
    ) -> AnyPublisher<PostAccountResponse, ServiceError> {
        RestfulManager.postElement(
            postAccount,
            on: self.baseUrl
        )
    }
    
    // MARK: GET /account/auth/verifyToken
    /// publishes a GET request to check whether token is valid
    public func verifyToken() -> AnyPublisher<[String: String], ServiceError> {
        RestfulManager.getElement(on: self.baseUrl + "/auth/verifyToken", query: nil)
    }
    
    public func deleteAccount(id: Int) -> AnyPublisher<PostAccountResponse, ServiceError> {
        RestfulManager.deleteElement(on: self.baseUrl, query: "id=\(id)")
    }
    
    // MARK: PATCH /account
    /// publishes a PATCH request with a patchAccountMediator payload in the body
    /// - Parameters
    ///     - patchAccount: PatchAccountMediator to be sent in the body
    public func patchAccount(
        _ patchAccount: PatchAccountMediator
    ) -> AnyPublisher<PostAccountResponse, ServiceError> {
        RestfulManager.patchElement(
            patchAccount,
            on: self.baseUrl
        )
    }
}
