//
//  PatientInfoSheet.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 16.07.21.
//

import SwiftUI
import Shared
import Combine
import HealthKit

struct PatientInfoSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var infoModel: InfoModel
    let patient: Int
    
    init(patient: Int) {
        self.patient = patient
        self.infoModel = InfoModel(patient: patient)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if infoModel.loadingState == .loadedSuccessfully {
                    if let trainingZones = infoModel.trainingZones {
                        buildTrainingZonesView(trainingZones.trainingZones)
                    }
                } else {
                    Text("loading".localized)
                }
                
                Spacer()
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close".localized)
                        .foregroundColor(.FontPrimary)
                        .font(.system(size: 20))
                }
                .padding(.bottom, 15)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Info")
        }
    }
    
    func buildTrainingZonesView(_ zones: [PatientTrainingZone]) -> some View {
        VStack(alignment: .center) {
            ForEach((0..<zones.count)) { idx in
                if let zone = zones[idx] {
                    VStack {
                        Text("\((HKWorkoutActivityType(rawValue: UInt(zone.workoutType)) ?? .walking).name)".localized + " \(self.infoSuffix(zone.unit))")
                            .foregroundColor(.Grey)
                        
                        HStack {
                            Group {
                                Text("\(zone.upper0Bound) \(self.unitSuffix(zone.unit))")
                                Text("\(zone.upper1Bound) \(self.unitSuffix(zone.unit))")
                                Text("\(zone.upper2Bound) \(self.unitSuffix(zone.unit))")
                                Text("\(zone.upper3Bound) \(self.unitSuffix(zone.unit))")
                            }
                            .padding()
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.FontPrimary)
                        }
                        
                        RangeGraph(zoneValues: [20, 20, 20, 20, 20], showPercentagesAsText: false)
                            .frame(height: 10)
                    }
                    Divider()
                } else {
                    EmptyView()
                }
            }
        }
        .padding()
    }
    
    func infoSuffix(_ unit: String) -> String {
        unit == "SPEED" ? "(Speed)".localized : "(Heart rate)".localized
    }
    
    func unitSuffix(_ unit: String) -> String {
        unit == "SPEED" ? "km/h" : "bpm"
    }
}

class InfoModel: ObservableObject {
    let patientService: PatientService
    @Published var trainingZones: GetTrainingZonesMediator?
    
    var cancellables: [AnyCancellable] = []
    var loadingState: LoadingState = .notStarted
    
    init(patient: Int) {
        self.patientService = PatientService()
        loadTrainingZones(patient: patient)
    }
    
    func loadTrainingZones(patient: Int) {
        patientService.getTrainingZones(identifier: patient)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        self.loadingState = .loadingFailed
                    }
                },
                receiveValue: { trainingZones in
                    self.trainingZones = trainingZones
                    self.loadingState = .loadedSuccessfully
                })
            .store(in: &cancellables)
    }
}
