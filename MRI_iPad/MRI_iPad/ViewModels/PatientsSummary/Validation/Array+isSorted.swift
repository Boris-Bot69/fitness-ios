//
//  Array+isSorted.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 02.07.21.
//

import Foundation

extension Array {
    func isSorted(_ isOrderedBefore: (Element, Element) -> Bool) -> Bool {
        guard !self.isEmpty else {
            return false
        }
        for index in 1..<self.count {
            if !isOrderedBefore(self[index - 1], self[index]) {
                return false
            }
        }
        return true
    }
}
