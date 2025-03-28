//
//  TableColumnHeaders.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 24.06.21.
//
import Foundation
import SwiftUI

struct TableColumnHeaders: View {
    @ObservedObject var viewModel: PatientsSummaryViewModel
    var columns: [GridItem]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading) {
            Checkbox(toggled: viewModel.selectedPatients.count >= viewModel.patients.count, onTap: viewModel.toggleAllPatients)
                .padding(.leading, 10)
                .padding(.trailing, 7)
            Group {
                SortableHeader(viewModel, SortState.sortBy { $0.lastName }, label: "Name".localized, sortState: $viewModel.sortStates[0])
                if columns.count > PatientsSummary.columnsLarge.count {  // full set of columns given
                    SortableHeader(viewModel, SortState.sortBy { $0.birthday }, label: "Born".localized, sortState: $viewModel.sortStates[1])
                }
                // hide From & To columns to save space in portrait mode
                if columns.count > PatientsSummary.columnsMedium.count {
                    SortableHeader(viewModel, SortState.sortBy { $0.treatmentStarted }, label: "From".localized, sortState: $viewModel.sortStates[2])
                    SortableHeader(
                        viewModel,
                        SortState.sortBy { $0.treatmentFinished ?? Date(timeIntervalSince1970: 0) },
                        label: "To".localized,
                        sortState: $viewModel.sortStates[3]
                    )
                }
            }
            SortableHeader(viewModel, SortState.sortBy { $0.weekProgress }, label: "Progress".localized, sortState: $viewModel.sortStates[4])
            SortableHeader(viewModel, SortState.sortBy { $0.totalHours }, label: "∑ h", sortState: $viewModel.sortStates[5])
            SortableHeader(viewModel, SortState.sortBy { $0.ratings }, label: "Ratings".localized, sortState: $viewModel.sortStates[6])
            SortableHeader(
                viewModel,
                SortState.sortBy { $0.trainingProgress },
                label: "Training quota".localized,
                sortState: $viewModel.sortStates[7]
            )
            SortableHeader(viewModel,
                           SortState.sortBy { $0.studyGroups.isEmpty ? ["z"] : $0.studyGroups },
                           label: "Type".localized,
                           sortState: $viewModel.sortStates[8])
            if columns.count > PatientsSummary.columnsSmall.count {
                Text("Heart rate".localized)
            }
            SortableHeader(viewModel, SortState.sortBy { $0.active }, label: "", sortState: $viewModel.sortStates[10])
        }
        .font(.system(size: 15).weight(.semibold))
    }
}
