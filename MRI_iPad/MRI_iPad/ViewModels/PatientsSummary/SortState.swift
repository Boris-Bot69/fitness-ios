//
//  SortState.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 22.06.21.
//

import Foundation
import Shared
import FontAwesomeSwiftUI

//State driving the SortableHeader sort function
enum SortState {
    case none
    case ascending
    case descending
    
    func next() -> SortState {
        switch self {
        case .none:
            return .ascending
        case .ascending:
            return .descending
        case .descending:
            return .ascending
        }
    }
    
    func getIcon() -> String {
        switch self {
        case .none:
            return AwesomeIcon.sort.rawValue
        case .ascending:
            return AwesomeIcon.sortUp.rawValue
        case .descending:
            return AwesomeIcon.sortDown.rawValue
        }
    }
    
    //Helper function to determine according to which attribute
    //the sorting function is applied in ascending order
    typealias SortBy<T> = (T, T) -> Bool
    static func sortBy<T, K>(
        _ key: @escaping (T) -> K)
    -> SortBy<T> where K: Comparable {
        { key($0) < key($1) }
    }
}
