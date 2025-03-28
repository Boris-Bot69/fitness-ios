//
//  ArrayExtension.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 25.06.21.
//

import Foundation

extension Array: Comparable where Element: Comparable {
    public static func < (lhs: [Element], rhs: [Element]) -> Bool {
        for (leftElement, rightElement) in zip(lhs, rhs) {
            return leftElement < rightElement
        }
        return lhs.count < rhs.count
    }
}

extension Sequence where Element: Hashable {
    ///Removes duplicates from a Sequence (e.g Array)
    public func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
