//
//  ArrayExtensions.swift
//  tumsm
//
//  Created by Paul Schmiedmayer on 10/11/19.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import Foundation


// MARK: Array + Replace and Sort
extension Array where Element: Identifiable & Codable & Comparable {
    /// Replaces all instances in the Array that have the same `id ` as `element`, appends the `element` and sorts the `Array` (in reverse order)
    /// - Parameter element: The `element` that is used to perform the `replaceAndSort` operation
    public mutating func replaceAndSort(_ element: Element) {
        removeAll(where: { $0.id == element.id })
        append(element)
        sort()
        reverse()
    }
}
