//
//  PatientRow.swift
//  DoctorsApp
//
//  Created by Patrick Witzigmann on 24.06.21.
//

import SwiftUI
import Shared
import FontAwesomeSwiftUI

struct PatientRow: View {
    var columns: [GridItem]
    @ObservedObject var viewModel: PatientsSummaryViewModel
    var patient: PatientSummary

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading) {
            Checkbox(toggled: viewModel.selectedPatients.contains(patient), onTap: toggleSelected)
                .padding(.leading, 10)
                .padding(.trailing, 7)
            Group { // prevent "Extra arguments at positions #11, #12, ..." error
                Text("\(patient.lastName), \(patient.firstName)")

                // hide Birthday on smaller devices to save space
                if columns.count >= PatientsSummary.columnsXLarge.count {
                    Text("\(patient.birthday.asDateString)")
                }

                // only show treatment dates for medium and above
                if columns.count >= PatientsSummary.columnsLarge.count {
                    Text("\(patient.treatmentStarted.asDateString)")
                    Text("\(patient.treatmentFinished.asDateString)")
                }
            }
            if patient.weekProgress.total != 0 {
                    let weekProgressPercent = Int(round(Double(patient.weekProgress.completed) / Double(patient.weekProgress.total) * 100))
                    Text("\(patient.weekProgress.completed) of \(patient.weekProgress.total) (\(weekProgressPercent)%)")
            } else { Text("") }
            Text("\(Int(patient.totalHours))h")
            TrainingsRatingsGraph(badRatings: patient.ratings.bad, mediumRatings: patient.ratings.medium, goodRatings: patient.ratings.good)

            TrainingsRateGraph(
                workoutsPlanned: patient.trainingProgress.total,
                workoutsRecorded: patient.trainingProgress.completed,
                alignment: .center
            ).padding(.trailing, 5)
            Text(patient.studyGroups.last ?? "")
            // hide heart rate graphs to save space in portrait mode
            if columns.count >= PatientsSummary.columnsMedium.count {
                rangeGraphs.padding(.vertical)
            }
            // active/inactive patient indicator
            (patient.active ? Color.DarkBlue : Color.SuperLightBlue)
                    .cornerRadius(5, corners: [.topRight, .bottomRight])
                .frame(height: 70)
        }
        .font(.subheadline)
    }

    var rangeGraphs: some View {
        VStack {
            if self.runningValues().max() != 0 {
                HStack {
                    Text(AwesomeIcon.running.rawValue)
                        .font(.awesome(style: .solid, size: 17))
                        .frame(width: 20)
                    RangeGraph(zoneValues: runningValues())
                }
            }
            if self.cyclingValues().max() != 0 {
                HStack {
                    Text(AwesomeIcon.biking.rawValue)
                        .font(.awesome(style: .solid, size: 17))
                        .frame(width: 20)
                    RangeGraph(zoneValues: cyclingValues())
                }
            }
        }
    }
    
    func runningValues() -> [Int] {
        [
            Int(patient.heartRateProfileRunning.zone0),
            Int(patient.heartRateProfileRunning.zone1),
            Int(patient.heartRateProfileRunning.zone2),
            Int(patient.heartRateProfileRunning.zone3),
            Int(patient.heartRateProfileRunning.zone4)
        ]
    }
    
    func cyclingValues() -> [Int] {
        [
            Int(patient.heartRateProfileCycling.zone0),
            Int(patient.heartRateProfileCycling.zone1),
            Int(patient.heartRateProfileCycling.zone2),
            Int(patient.heartRateProfileCycling.zone3),
            Int(patient.heartRateProfileCycling.zone4)
        ]
    }
    
    func toggleSelected() {
        viewModel.togglePatient(patientId: self.patient.id)
    }
}

//swiftlint:disable closure_body_length
struct PatientRow_Previews: PreviewProvider {
    static var model: PatientsSummaryViewModel {
        let model = PatientsSummaryViewModel()
        let mockModel = MockModel()
        mockModel.loadPatientsSummaries()
        model.patients = mockModel.patientsSummaries ?? []
        model.loadingState = .loadedSuccessfully
        return model
    }

    static var previews: some View {
        VStack(spacing: 20) {
            Text(String("iPad Pro 12.9\" landscape"))
            PatientRow(columns: PatientsSummary.columnsXLarge, viewModel: model, patient: model.patients[1])
                .padding(.horizontal, 10)
                // grey border
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.LightGrey, lineWidth: 1)
                        .padding(.horizontal, 10)
                )
                .frame(width: 1366, height: 90)
                .border(Color.black)

            Text(String("iPad Pro 11\" landscape"))
            PatientRow(columns: PatientsSummary.columnsLarge, viewModel: model, patient: model.patients[1])
                .padding(.horizontal, 10)
                // grey border
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.LightGrey, lineWidth: 1)
                        .padding(.horizontal, 10)
                )
                .frame(width: 1194, height: 90)
                .border(Color.black)

            Text(String("iPad Pro 12.9\" portrait"))
            PatientRow(columns: PatientsSummary.columnsMedium, viewModel: model, patient: model.patients[1])
                .padding(.horizontal, 10)
                // grey border
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.LightGrey, lineWidth: 1)
                        .padding(.horizontal, 10)
                )
                .frame(width: 1024, height: 90)
                .border(Color.black)

            Text(String("iPad Pro 11\" portrait"))
            PatientRow(columns: PatientsSummary.columnsSmall, viewModel: model, patient: model.patients[1])
                .padding(.horizontal, 10)
                // grey border
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.LightGrey, lineWidth: 1)
                        .padding(.horizontal, 10)
                )
                .frame(width: 834, height: 90)
                .border(Color.black)
        }.previewLayout(.fixed(width: 1366, height: 600)) // iPad Pro 12.9" landscape width
    }
}
