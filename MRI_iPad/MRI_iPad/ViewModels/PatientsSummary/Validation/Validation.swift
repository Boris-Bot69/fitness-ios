//
//  Validation.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 01.07.21.
//

import Foundation
import Combine
import SwiftUI

enum Validation {
    case success
    case failure(message: String)
    
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var getMessage: String {
        switch self {
        case .success:
            return ""
        case .failure(message: let message):
            return message
        }
    }
}

typealias ValidationErrorClosure = () -> String
typealias ValidationPublisher = AnyPublisher<Validation, Never>

enum ValidationPublishers {
    // Validates publisher according to expression
    static func validate<T>(for publisher: Published<T>.Publisher,
                            errorMessage: @autoclosure @escaping ValidationErrorClosure,
                            expression: @escaping (T) -> Bool ) -> ValidationPublisher {
        publisher.map { value in
            guard expression(value) else {
                return .failure(message: errorMessage())
            }
            return .success
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
    
    // Validates whether a string matches a regular expression.
    static func patternValidation(for publisher: Published<String>.Publisher,
                                  pattern: String,
                                  errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        publisher.map { value in
            guard value.range(of: pattern, options: .regularExpression) != nil else {
                return .failure(message: errorMessage())
            }
            return .success
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
    // Validates whether an optional string matches a regular expression.
    static func patternValidation(for publisher: Published<String?>.Publisher,
                                  pattern: String,
                                  errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        publisher.map { value in
            guard let string = value else {
                return .success
            }
            guard string.range(of: pattern, options: .regularExpression) != nil else {
                return .failure(message: errorMessage())
            }
            return .success
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
    
    // combine two publisher together
    static func combine(_ first: ValidationPublisher, _ second: ValidationPublisher) -> ValidationPublisher {
        first
            .combineLatest(second)
            .map { value1, value2 in
                [value1, value2]
                    .allSatisfy { $0.isSuccess } ? Validation.success : .failure(message: !value1.isSuccess ? value1.getMessage : value2.getMessage)
            }
            .eraseToAnyPublisher()
    }
    
    //combining all publishers together, swift only support combineLatest4
    static func combineAll(_ validators: ValidationPublisher...) -> ValidationPublisher {
        var ret: ValidationPublisher = validators[0]
        for index in 1..<validators.count {
            ret = combine(ret, validators[index])
        }
        return ret
    }
    
    static func combineAll(_ validators: [ValidationPublisher]) -> ValidationPublisher {
        var ret: ValidationPublisher = validators[0]
        for index in 1..<validators.count {
            ret = combine(ret, validators[index])
        }
        return ret
    }
}

//extension to have string float value as an attribute
extension String {
    static let numberFormatter = NumberFormatter()
    
    var floatValue: Float? {
        String.numberFormatter.number(from: self)?.floatValue
    }
    
    var intValue: Int? {
        String.numberFormatter.number(from: self)?.intValue
    }
    
    func dateValue(_ dateFormat: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: self)
    }
}
