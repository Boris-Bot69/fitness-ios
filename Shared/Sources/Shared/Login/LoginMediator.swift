//
//  LoginMediator.swift
//  
//
//  Created by Jannis Mainczyk on 08.07.21.
//

import Foundation

/// Response object of authentication endpoint (`/account/auth`)
public struct LoginMediator: Codable {
    public let token: String
    public let patientId: Int?
    public let trainerId: Int?
}
