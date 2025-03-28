//
//  SortableHeader.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 22.06.21.
//
//swiftlint:disable type_name

import SwiftUI
import FontAwesomeSwiftUI

protocol SortableHeaderViewModel: ObservableObject {
    //indicates the object that are passed to the list (table)
    associatedtype T
    
    ///Sort the function with a descriptor that describes sort in ascending order
    ///- Parameters:
    ///     descriptor: defines if the left object is ordered before the right object
    ///     ascending: if false the sort should in reversed order
    func sort(descriptor: @escaping (T, T) -> Bool, ascending: Bool)
    
    ///Reset the state of other headers to none
    func reset()
}

///Headers for the PatientsOverview table for sortable headers
struct SortableHeader<V: SortableHeaderViewModel>: View {
    @ObservedObject var viewModel: V
    @Binding var sortState: SortState
    var label: String
    let descriptor: (V.T, V.T) -> Bool
    
    init(_ viewModel: V, _ descriptor: @escaping (V.T, V.T) -> Bool, label: String, sortState: Binding<SortState>) {
        self.viewModel = viewModel
        self.descriptor = descriptor
        self.label = label
        self._sortState = sortState
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15).weight(.semibold))
                .padding(.trailing, 0)
                .multilineTextAlignment(.center)
            Text(sortState.getIcon()).font(.awesome(style: .solid, size: 15))
        }
        .foregroundColor(.FontPrimary)
        .onTapGesture {
            sort()
        }
    }
    
    private func sort() {
        let tmpState = sortState.next()
        viewModel.reset()
        sortState = tmpState
        let ascending: Bool
        switch sortState {
        case .none:
            print("none should not be here, going to default value -> ascending")
            ascending = true
            sortState = sortState.next()
        case .ascending:
            ascending = true
        case .descending:
            ascending = false
        }
        viewModel.sort(descriptor: descriptor, ascending: ascending)
    }
}
