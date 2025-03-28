//
//  Publisher+Validator.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 02.07.21.
//

import SwiftUI
import Shared
import HealthKit

extension Published.Publisher where Value == String {
    func notEmptyValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage(), expression: { !$0.isEmpty })
    }
    
    func patternValidator(_ pattern: String, _ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.patternValidation(for: self, pattern: pattern, errorMessage: errorMessage())
    }
    
    func intValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage(), expression: { $0.intValue != nil })
    }
    
    func validIntValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage()) {
            guard let int = $0.intValue else {
                return false
            }
            return int > 0 && int < 1000
        }
    }
    
    func floatValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage(), expression: { $0.floatValue != nil })
    }
    
    func validFloatValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage()) {
            guard let float = $0.floatValue else {
                return false
            }
            return float > 0.0 && float < 999.9
        }
    }
    
    func dateValidator(_ dateFormat: String, _ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage(), expression: { $0.dateValue(dateFormat) != nil })
    }
    
    func dateValidator(
        _ dateFormat: String,
        isAfter: Published<String>.Publisher,
        _ errorMessage: @autoclosure @escaping ValidationErrorClosure
    ) -> ValidationPublisher {
        isAfter
            .combineLatest(self)
            .map { value1, value2 in
                guard let first = value1.dateValue(dateFormat), let second = value2.dateValue(dateFormat), first < second else {
                    return .failure(message: errorMessage())
                }
                return .success
            }
            .dropFirst()
            .eraseToAnyPublisher()
    }
}

extension Published.Publisher where Value == StudyGroup? {
    func notEmptyValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage(), expression: { $0 != nil })
    }
}

extension Published.Publisher where Value == Unit? {
    func notEmptyValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage(), expression: { $0 != nil })
    }
}

extension Published.Publisher where Value == HKWorkoutActivityType? {
    func notEmptyValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage(), expression: { $0 != nil })
    }
}

extension Published.Publisher where Value == [String] {
    func notEmptyValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage(), expression: { !$0.contains("") })
    }
    
    func intElementsValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage()) {
            !$0.map { $0.intValue }.contains { $0 == nil }
        }
    }
    
    func validElementsValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage()) {
            let intArray = $0.map { $0.intValue }
            return !intArray.contains { $0 ?? -1 < 1 } && !intArray.contains { $0 ?? -1 > 999 }
        }
    }
    
    func orderedElementsValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage()) {
            $0.isSorted { $0.intValue ?? -1 < $1.intValue ?? -1 }
        }
    }
}

extension Published.Publisher where Value == String? {
    func patternValidator(_ pattern: String, _ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.patternValidation(for: self, pattern: pattern, errorMessage: errorMessage())
    }
    
    func dateValidator(_ dateFormat: String, _ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage()) {
            $0 == nil || ($0 != nil && $0?.dateValue(dateFormat) != nil)
        }
    }
    
    func dateValidator(
        _ dateFormat: String,
        isAfter: Published<String>.Publisher,
        _ errorMessage: @autoclosure @escaping ValidationErrorClosure
    ) -> ValidationPublisher {
        isAfter
            .combineLatest(self)
            .map { value1, value2 in
                guard let first = value1.dateValue(dateFormat), let second = value2?.dateValue(dateFormat), first < second else {
                    return .failure(message: errorMessage())
                }
                return .success
            }
            .dropFirst()
            .eraseToAnyPublisher()
    }
    
    func intValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage()) {
            $0 == nil || ($0 != nil && $0?.intValue != nil)
        }
    }
    
    func floatValidator(_ errorMessage: @autoclosure @escaping ValidationErrorClosure) -> ValidationPublisher {
        ValidationPublishers.validate(for: self, errorMessage: errorMessage()) {
            $0 == nil || ($0 != nil && $0?.floatValue != nil)
        }
    }
}
