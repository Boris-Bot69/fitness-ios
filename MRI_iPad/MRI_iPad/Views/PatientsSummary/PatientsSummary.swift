//
//  PatientsSummary.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 12.05.21.
//

import Shared
import SwiftUI
import Introspect

struct PatientsSummary: View {
    @ObservedObject var viewModel: PatientsSummaryViewModel
    @State var disableView = false
    @State var isStartDate = false
    @State var startDate = Date()
    @State var endDate = Date()
    @State var deleteAlert = false
    @State var presentAddNewAccount = false
    let refreshHelper = RefreshHelper()
    
    private var enableExport: Binding<Bool> {
        Binding(get: { !viewModel.selectedPatients.isEmpty }, set: { _ in })
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Toolbar(
                    viewModel: viewModel,
                    isStartDate: $isStartDate,
                    disableView: $disableView,
                    startDate: $startDate,
                    endDate: $endDate
                ).padding(.leading, 24)
                TableColumnHeaders(viewModel: viewModel, columns: columns(for: geometry))
                patientTable(for: geometry)
                Spacer()
            }.padding(.horizontal, 10)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("All Patients".localized)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                addNewAccountButton
            }
        }
        .sheet(isPresented: $presentAddNewAccount) {
            EditPatient(viewModel: EditPatientViewModel(patient: viewModel.selectedEditPatient))
                .environment(\.refresh) {
                    viewModel.selectedEditPatient = nil
                    viewModel.loadPatientSummaries()
                }
                .id(UUID())
        }
        .overlay(
            DatePickerOverlay(
                disableView: $disableView,
                isStartDate: $isStartDate,
                selectedStartDate: $startDate,
                selectedEndDate: $endDate
            )
        )
    }

    private var editAction: some Action {
        EditAction {
            self.presentAddNewAccount = true
        }
    }

    func patientTable(for geometry: GeometryProxy) -> some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                switch viewModel.loadingState {
                case .loadedSuccessfully:
                    ForEach(viewModel.patients, id: \.id) { patient in
                        NavigationLink(destination: PatientOverview(patientSummary: patient)) {
                            patientRow(patient, for: geometry)
                        }
                    }
                case .notStarted:
                    Text("About to load patients")
                case .loading:
                    Text("Loading patients...")
                case .loadingFailed:
                    Text("Couldn't load patients!")
                }
            }
        }
        .introspectScrollView {
            let refresh = UIRefreshControl()
            refreshHelper.parent = self
            refreshHelper.refreshControl = refresh
            refresh.addTarget(refreshHelper, action: #selector(refreshHelper.didRefresh), for: .valueChanged)
            $0.refreshControl = refresh
        }
    }

    func patientRow(_ patient: PatientSummary, for geometry: GeometryProxy) -> some View {
        PatientRow(columns: columns(for: geometry), viewModel: viewModel, patient: patient)
            // apply grey border with rounded corners
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.LightGrey, lineWidth: 1)
                    .foregroundColor(.clear)
            )
.swipeActions(leading:
    EditAction {
        viewModel.selectedEditPatient = patient
        self.presentAddNewAccount = true
    }, trailing: DeleteAction(alert: "\(patient.lastName), \(patient.firstName)") {
    viewModel.delete(patient: patient)
    })
.padding(.bottom, 8)
    }

    private var addNewAccountButton: some View {
        Button(action: {
            viewModel.selectedEditPatient = nil
            self.presentAddNewAccount = true
        }) {
            Image(systemName: "plus")
        }
    }
    
    func removePatient(at offsets: IndexSet) {
        viewModel.patients.remove(atOffsets: offsets)
    }

    /// - MARK: Responsiveness
    /// Return columns that fit the given geometry (based on width)
    func columns(for geometry: GeometryProxy) -> [GridItem] {
        switch geometry.size.width {
        case ..<1024:
            return PatientsSummary.columnsSmall
        case 1024..<1194:
            return PatientsSummary.columnsMedium
        case 1194..<1366:
            return PatientsSummary.columnsLarge
        case 1366...:
            return PatientsSummary.columnsXLarge
        default:
            return PatientsSummary.columnsXLarge
        }
    }

    /// Full set of columns for large screens with widths greater than 1300px.
    static var columnsXLarge: [GridItem] = [
        columnCheckbox,
        columnName,
        columnDate,  // Birthday          ("Born")
        columnDate,  // Treatment Started ("From")
        columnDate,  // Treatment Ended   ("To")
        columnProgress,
        columnTotalHours,
        columnRatings,
        columnTrainingQuota,
        columnStudyGroup,
        columnHeartRate,
        columnActiveIndicator
    ]

    /// Like `columnsXLarge`, but without birthday column.
    static var columnsLarge: [GridItem] = [
        columnCheckbox,
        columnName,
        columnDate,  // Treatment Started ("From")
        columnDate,  // Treatment Ended   ("To")
        columnProgress,
        columnTotalHours,
        columnRatings,
        columnTrainingQuota,
        columnStudyGroup,
        columnHeartRate,
        columnActiveIndicator
    ]

    /// Like `columnsLarge`, but without treatment dates.
    static var columnsMedium: [GridItem] = [
        columnCheckbox,
        columnName,
        columnProgress,
        columnTotalHours,
        columnRatings,
        columnTrainingQuota,
        columnStudyGroup,
        columnHeartRate,
        columnActiveIndicator
    ]

    /// Like `columnsCondensed`, but without treatment started, treatment ended and heart rate columns.
    static var columnsSmall: [GridItem] = [
        columnCheckbox,
        columnName,
        columnProgress,
        columnTotalHours,
        columnRatings,
        columnTrainingQuota,
        columnStudyGroup,
        columnActiveIndicator
    ]

    //swiftlint:disable colon
    static var columnCheckbox:          GridItem { .init(.fixed( 40)) }
    static var columnName:              GridItem { .init(.flexible(minimum:  80, maximum: 160)) }
    static var columnDate:              GridItem { .init(.fixed( 90)) }
    static var columnProgress:          GridItem { .init(.fixed(123)) }
    static var columnTotalHours:        GridItem { .init(.fixed( 65)) }
    static var columnRatings:           GridItem { .init(.fixed( 90)) }
    static var columnTrainingQuota:     GridItem { .init(.fixed(125)) }
    static var columnStudyGroup:        GridItem { .init(.flexible(minimum: 100, maximum: 140)) }
    static var columnHeartRate:         GridItem { .init(.flexible(minimum:  90, maximum: 230)) }
    static var columnActiveIndicator:   GridItem { .init(.fixed( 30)) }
}


struct PatientsSummary_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PatientsSummary(viewModel: MockPatientsSummaryViewModel())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .foregroundColor(Color.FontPrimary)
        .previewLayout(.fixed(width: 1366, height: 400)) // iPad Pro 12.9" landscape

        NavigationView {
            PatientsSummary(viewModel: MockPatientsSummaryViewModel())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .foregroundColor(Color.FontPrimary)
        .previewLayout(.fixed(width: 1194, height: 400))   // iPad Pro 11" in landscape

        NavigationView {
            PatientsSummary(viewModel: MockPatientsSummaryViewModel())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .foregroundColor(Color.FontPrimary)
        .previewLayout(.fixed(width: 1024, height: 400))   // iPad Pro 12.9" in portrait

        NavigationView {
            PatientsSummary(viewModel: MockPatientsSummaryViewModel())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .foregroundColor(Color.FontPrimary)
        .previewLayout(.fixed(width: 834, height: 400))   // iPad Pro 11" in portrait
    }
}

class RefreshHelper {
    var parent: PatientsSummary?
    var refreshControl: UIRefreshControl?
    
    @objc
    func didRefresh() {
        guard let parent = parent, let refreshControl = refreshControl else {
            return
        }
        parent.viewModel.loadPatientSummaries()
        refreshControl.endRefreshing()
    }
}
