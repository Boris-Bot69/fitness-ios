//
//  EditPatient.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 22.06.21.
//

import Shared
import SwiftUI

//swiftlint:disable closure_body_length line_length force_unwrapping
struct EditPatient: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.refresh) private var refresh
    @ObservedObject var viewModel: EditPatientViewModel
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }
    
    init(viewModel: EditPatientViewModel) {
        self.viewModel = viewModel
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.DarkBlue)]
        UINavigationBar.appearance().tintColor = UIColor(Color.DarkBlue)
    }
    
    var body: some View {
        NavigationView {
            self.form
                .navigationBarTitle(viewModel.patient == nil ? "Create Patient Account".localized : "Edit Patient Account".localized, displayMode: .inline)
                .toolbar {
                    SaveButton(viewModel: viewModel) {
                    }.buttonStyle(ProgressViewButtonStyle(animating: $viewModel.showPatchProgressView))
                }
                .alert(isPresented: $viewModel.presentAlert) {
                    Alert(title: Text(viewModel.errorHeader),
                          message: Text(viewModel.errorMessage),
                          dismissButton: .default(Text("Okay".localized)))
                }
                .onReceive(viewModel.dismissFormPublisher) {
                    if $0 {
                        refresh()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        }
        .foregroundColor(.DarkBlue)
        .navigationViewStyle(StackNavigationViewStyle())
        .overlay(Credentials(viewModel: viewModel))
        .overlay(StudyGroupPicker(viewModel: viewModel))
    }
    
    var form: some View {
        Form {
            Section(header: Text("Patient Profile")) {
                Toggle(isOn: $viewModel.active, label: {
                    Text("Active")
                })
                .toggleStyle(ActiveToggleStyle())
                .padding(.vertical, 5)
                Group {
                    TextField("Username", text: $viewModel.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .validation(viewModel.usernameValidator)
                    TextField("First Name", text: $viewModel.firstName)
                        .disableAutocorrection(true)
                        .validation(viewModel.firstNameValidator)
                    TextField("Last Name", text: $viewModel.lastName)
                        .disableAutocorrection(true)
                        .validation(viewModel.lastNameValidator)
                    TextField("Email Address", text: $viewModel.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .validation(viewModel.emailAddressValidator)
                    HStack {
                        TextField("Day of birth".localized + " (dd.mm.yyyy)", text: $viewModel.birthday)
                            .validation(viewModel.birthdayValidator)
                        DatePicker(selection: Binding<Date>(get: { dateFormatter.date(from: viewModel.birthday) ?? Date() }, set: { viewModel.birthday = dateFormatter.string(from: $0) }), displayedComponents: [.date]) {
                        }
                        .accentColor(.DarkBlue)
                        .onTapGesture {
                            if dateFormatter.date(from: viewModel.birthday) == nil {
                                viewModel.birthday = Date().asDateString
                            }
                        }
                    }
                    Picker((viewModel.gender == nil ? "Gender".localized + " (Optional)" : viewModel.gender?.name.localized)!, selection: $viewModel.gender) {
                        ForEach(Gender.allCases, id: \.self) {
                            Text($0.name).tag($0 as Gender?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .id(viewModel.gender)
                    .padding(.vertical, 10)
                    TextField("Weight".localized + " (Optional)", text: Binding(get: { viewModel.weight ?? "" }, set: {
                        if $0.isEmpty {
                            viewModel.weight = nil
                        } else {
                            viewModel.weight = $0
                        }
                    }))
                    .validation(viewModel.weightValidator)
                    TextField("Height".localized + " (Optional)", text: Binding(get: { viewModel.height ?? "" }, set: {
                        if $0.isEmpty {
                            viewModel.height = nil
                        } else {
                            viewModel.height = $0
                        }
                    }))
                    .validation(viewModel.heightValidator)
                }.disabled(!viewModel.active)
            }
            Section(header: Text("Treatment".localized)) {
                Button((viewModel.selectedStudyGroup == nil ? "Study Group".localized : viewModel.selectedStudyGroup?.name)!) {
                    viewModel.showStudyGroupPicker = true
                }
                .padding(.vertical, 10)
                HStack {
                    TextField("Start Date".localized + " (dd.mm.yyyy)", text: $viewModel.startDate)
                        .validation(viewModel.startDateValidator)
                    DatePicker(selection: Binding<Date>(get: { dateFormatter.date(from: viewModel.startDate) ?? Date() }, set: { viewModel.startDate = dateFormatter.string(from: $0) }), displayedComponents: [.date]) {
                    }
                    .accentColor(.DarkBlue)
                    .onTapGesture {
                        if dateFormatter.date(from: viewModel.startDate) == nil {
                            viewModel.startDate = Date().asDateString
                        }
                    }
                }
                HStack {
                    TextField("End Date".localized + " (dd.mm.yyyy)", text: $viewModel.endDate).validation(viewModel.endDateValidator)
                    DatePicker(selection: Binding<Date>(get: { dateFormatter.date(from: viewModel.endDate) ?? Date() }, set: { viewModel.endDate = dateFormatter.string(from: $0) }), displayedComponents: [.date]) {
                    }
                    .accentColor(.DarkBlue)
                    .onTapGesture {
                        if dateFormatter.date(from: viewModel.endDate) == nil {
                            viewModel.endDate = Date().asDateString
                        }
                    }
                }
                TextField("Goal".localized, text: $viewModel.goal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .validation(viewModel.goalValidator)
                TextField("Comment".localized + " (Optional)", text: Binding(get: { viewModel.comment ?? "" }, set: {
                    if $0.isEmpty {
                        viewModel.comment = nil
                    } else {
                        viewModel.comment = $0
                    }
                }))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .validation(viewModel.commentValidator)
            }.disabled(!viewModel.active)
            EditTrainingZones(viewModel: viewModel)
        }
        .onReceive(viewModel.formValidator, perform: { valid in
            viewModel.disableSaveButton = !valid.isSuccess
        })
    }
}

struct AddPatientAccount_Previews: PreviewProvider {
    static var previews: some View {
        EditPatient(viewModel: EditPatientViewModel())
    }
}
