//
//  EditTrainingZones.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 14.07.21.
//swiftlint:disable closure_body_length

import SwiftUI
import HealthKit

struct EditTrainingZones: View {
    @ObservedObject var viewModel: EditPatientViewModel
    var body: some View {
        Section(header: Text("Training Zones".localized)) {
            ForEach(viewModel.trainingZones.indices) { index in
                VStack(alignment: .leading) {
                    HStack {
                        Picker(selection: $viewModel.trainingZones[index].workoutType,
                               label:
                                HStack {
                                    if let label = viewModel.trainingZones[index].workoutType?.name {
                                        Text(label)
                                    } else {
                                        HStack {
                                            Image(systemName: "plus")
                                            Text("Workout Type".localized)
                                        }.foregroundColor(Color(UIColor.systemGray2))
                                    }
                                }
                        ) {
                            ForEach(viewModel.workoutTypes, id: \.self) {
                                Text($0.name.localized).tag($0 as HKWorkoutActivityType?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        Spacer()
                        Button(action: {
                            if viewModel.trainingZones.count > 1 {
                                viewModel.trainingZones.remove(at: index)
                            }
                        }, label: {
                            Image(systemName: "trash")
                        }).frame(width: 40, height: 20)
                    }.padding(.bottom, 5)
                    
                    HStack {
                        ForEach(0..<viewModel.trainingZones[index].values.count, id: \.self) { idx in
                            TextField("Value \(idx + 1)", text: $viewModel.trainingZones[index].values[idx])
                        }
                        Picker(selection: $viewModel.trainingZones[index].unit,
                               label:
                                HStack {
                                    if let label = viewModel.trainingZones[index].unit?.name {
                                        Text(label)
                                    } else {
                                        HStack {
                                            Image(systemName: "plus")
                                            Text("Unit".localized)
                                        }.foregroundColor(Color(UIColor.systemGray2))
                                    }
                                }
                        ) {
                            ForEach(viewModel.units, id: \.self) {
                                Text($0.name).tag($0 as Unit?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                .validation(viewModel.trainingZones[index].trainingZonesValidator)
            }.id(viewModel.trainingZones)
            Button(action: {
                if viewModel.trainingZones.count < 4 {
                    viewModel.addTrainingZones()
                }
            }, label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Training Zones")
                }
            })
        }
    }
}

struct EditTrainingZones_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            EditTrainingZones(viewModel: EditPatientViewModel())
        }
        .frame(width: 600, height: 180, alignment: .center)
        .previewLayout(.sizeThatFits)
    }
}
