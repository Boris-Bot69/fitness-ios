//
//  File.swift
//  
//
//  Created by Daniel Nugraha on 11.07.21.
// swiftlint:disable discouraged_optional_boolean

import Foundation
/// Mediator Object for  a patch account request
public struct PatchAccountMediator: Codable {
    let id: Int
    let username: String?
    let email: String?
    let password: String?
    let birthday: String?
    let firstName: String?
    let lastName: String?
    let active: Bool?
    
    public init(
        id: Int,
        username: String? = nil,
        email: String? = nil,
        password: String? = nil,
        birthday: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        active: Bool? = nil
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.password = password
        self.birthday = birthday
        self.firstName = firstName
        self.lastName = lastName
        self.active = active
    }
}
