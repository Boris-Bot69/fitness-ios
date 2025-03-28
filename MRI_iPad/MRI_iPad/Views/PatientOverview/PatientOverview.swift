//
//  PatientOverview.swift
//  DoctorsApp
//
//  Created by Denis Graipel on 14.05.21.
//

import SwiftUI
import Shared
import Combine
import FontAwesomeSwiftUI

struct PatientOverview: View {
    @ObservedObject var calendar = CalendarModel()
    @ObservedObject var viewModel = PatientOverviewViewModel()
    @EnvironmentObject var model: Model

    @State var showInfoSheet = false
    @State var uploadTrainingsPlan = false

    var patientSummary: PatientSummary

    init(patientSummary: PatientSummary) {
        self.patientSummary = patientSummary
    }

    var body: some View {
        VStack {
            Group {
                HStack {
                    calendarControl
                        // visually align with summary icons below
                        .padding(.horizontal, 8)
                    patientInfo
                    Spacer()
                }.padding(.top)
                if let overview = model.patientMonthlyActivity?.runningOverview {
                    if overview.duration > 0 {
                        ActivityOverviewBox(type: .running, overview: overview)
                    }
                }
                if let overview = model.patientMonthlyActivity?.cyclingOverview {
                    if overview.duration > 0 {
                        ActivityOverviewBox(type: .cycling, overview: overview)
                    }
                }
            }.padding(.horizontal)
            Group {
                switch model.patientWorkoutsOverviewLoadingState {
                case .loadedSuccessfully:
                    PatientCalendar(calendar)
                case .loading:
                    Text("Loading calendar...".localized)
                default:
                    Text("Could not load calendar!".localized)
                }
            }.padding(.top)
            Spacer(minLength: 0)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack {
                    toolbarButtons
                        .padding(.trailing, 30)
                        .padding(.top, 4)
                }
            }
        }
        .fileImporter(
            isPresented: $uploadTrainingsPlan,
            allowedContentTypes: [XlsxDocument.xlsxType],
            allowsMultipleSelection: false
        ) { resultWithUrlsOrError in
            switch resultWithUrlsOrError {
            case .success(let urls):
                viewModel.uploadTrainingPlan(
                    patientId: patientSummary.id,
                    withUrls: urls
                )
            case .failure(let error):
                print(error.localizedDescription)
                viewModel.showFailureTrainingsplanUploadAlert = true
            }
        }
        .sheet(isPresented: self.$showInfoSheet) {
            PatientInfoSheet(patient: patientSummary.id)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(patientSummary.firstName) \(patientSummary.lastName)")
        .onAppear(perform: {
            model.loadPatientWorkoutsOverview(
                patientSummary.id,
                startDate: calendar.currentMonth.firstDayOfTheWeek,
                endDate: calendar.currentMonth.lastDayOfTheMonth.lastDayOfTheWeek
            )
            model.loadMonthlyActivity(patientSummary.id, month: calendar.currentMonth)
        })
        .alert(isPresented: $viewModel.showAlert) {
            if viewModel.showSuccessTrainingsplanUploadAlert {
                return Alert(title: Text("Trainingsplan uploaded successfully".localized), message: Text(""), dismissButton: .default(Text("ok")))
            } else {
                return Alert(
                    title: Text("Trainingsplan upload failed".localized),
                    message: Text("Please check if your trainingsplan has the right format and try again.".localized),
                    dismissButton: .default(Text("Got it!".localized)))
            }
        }
    }

    var patientInfo: some View {
        HStack {
            StackView(label: "Study Group".localized) {
                Text(model.patientWorkoutsOverview?.studyGroup ?? "undefined".localized)
            }
            StackView(label: "Goal".localized) {
                Text(model.patientWorkoutsOverview?.treatmentGoal ?? "undefined".localized)
            }
            Spacer()
        }
    }

    var calendarControl: some View {
        HStack {
            Button(action: {
                calendar.prevMonth()
                model.loadPatientWorkoutsOverview(
                    patientSummary.id,
                    startDate: calendar.currentMonth.firstDayOfTheWeek,
                    endDate: calendar.currentMonth.lastDayOfTheMonth.lastDayOfTheWeek
                )
                model.loadMonthlyActivity(patientSummary.id, month: calendar.currentMonth)
                calendar.getSheet()
            }) {
                Image(systemName: "chevron.backward")
            }
            .buttonStyle(CalendarNavigationButtonStyle())

            Text("\(calendar.calNavigation)")
                .font(Font.custom("", size: 26))
                .fontWeight(.heavy)
                .frame(width: 200)

            Button(action: {
                calendar.nextMonth()
                model.loadPatientWorkoutsOverview(
                    patientSummary.id,
                    startDate: calendar.currentMonth.firstDayOfTheWeek,
                    endDate: calendar.currentMonth.lastDayOfTheMonth.lastDayOfTheWeek
                )
                model.loadMonthlyActivity(patientSummary.id, month: calendar.currentMonth)
                calendar.getSheet()
            }) {
                Image(systemName: "chevron.forward")
            }
            .buttonStyle(CalendarNavigationButtonStyle())
        }
    }

    var toolbarButtons: some View {
        // Setting FontAwesome-Icon has not worked
        return Group {
            Button(action: {
                self.showInfoSheet.toggle()
            }) {
                Text(AwesomeIcon.infoCircle.rawValue)
                    .font(.awesome(style: .solid, size: 30))
                    .foregroundColor(.DarkBlue)
                    .padding(.trailing, 3)
            }

            Button(action: {
                openEmailApp()
            }) {
                Text(AwesomeIcon.envelope.rawValue)
                    .font(.awesome(style: .regular, size: 30))
                    .foregroundColor(.DarkBlue)
                    .padding(.trailing, 3)
            }
                
            Button(action: {
                uploadTrainingsPlan.toggle()
            }) {
                Text(AwesomeIcon.calendarPlus.rawValue)
                    .font(.awesome(style: .regular, size: 28))
                    .foregroundColor(.DarkBlue)
                    .padding(.trailing, 15)
            }
            .padding(.trailing, -15)
        }
    }

    // This function will open default Mail-App on the iPad if installed.
    // To test this, you need to run the app on a real device because its not possible to install the Mail-App on the simulator
    // The Subject and body of the Mail will be prefilled by our app as followed:
    // Subject: "Dein Training"
    // Text (Body): "Hallo FIRSTNAME,"
    func openEmailApp() {
        let email = patientSummary.email ?? ""
        let subject = "Your training".localized.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = ("Hello ".localized + "\(patientSummary.firstName)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlString = "mailto:\(email)?subject=\(subject)&body=\(body)"

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

struct CalendarNavigationButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(Color.DarkBlue)
            .cornerRadius(8)
            .font(Font.system(size: 18).bold())
    }
}

struct PatientOverview_Previews: PreviewProvider {
    static func getMockModelForPatientCalendar() -> Model {
        let model = MockModel()
        model.loadPatientsSummaries()
        model.loadPatientWorkoutsOverview(5)
        return model
    }

    static var previews: some View {
        PatientOverview(
            patientSummary: MockModelFactory.createPatientsSummaries()[0]
        )
        .environmentObject(PatientOverview_Previews.getMockModelForPatientCalendar() as Model)
        // iPad Pro 12.9" landscape viewport
        .previewLayout(.fixed(width: 1366, height: 1024))
    }
}
