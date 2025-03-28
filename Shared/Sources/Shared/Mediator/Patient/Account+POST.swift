//
//  PostAccount.swift
//  
//
//  Created by Daniel Nugraha on 22.06.21.
//

import Foundation

/// Mediator Object for  a post account request
public struct PostAccountMediator: Codable {
    let username: String
    let email: String
    let password: String
    let birthday: String
    let firstName: String
    let lastName: String
    
    public init(
        _ username: String,
        email: String,
        password: String,
        birthday: String,
        firstName: String,
        lastName: String
    ) {
        self.username = username
        self.email = email
        self.password = password
        self.birthday = birthday
        self.firstName = firstName
        self.lastName = lastName
    }
}
/// Mediator Object for  a post account
public struct PostAccountResponse: Codable {
    public let account: Int
}
