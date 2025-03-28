//
//  Toolbar.swift
//  DoctorsApp
//
//  Created by Daniel Nugraha on 18.06.21.
//
import Foundation
import SwiftUI

struct Toolbar: View {
    @ObservedObject var viewModel: PatientsSummaryViewModel
    @State var chooseTimeRange = false
    @State var presentFileExporter = false
    @Binding var isStartDate: Bool
    @Binding var disableView: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    var body: some View {
        HStack {
            if !viewModel.selectedPatients.isEmpty {
                Button {
                    presentFileExporter = true
                    viewModel.export()
                } label: {
                    HStack {
                        Text("Export")
                        if viewModel.receivingExportFiles {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.horizontal, 5)
                        }
                    }
                    .buttonStyled()
                    .padding(.trailing, 18)
                }
            }
            if let from = viewModel.selectedStartDate, let toDate = viewModel.selectedEndDate {
                Text("\(dateFormatter.string(from: from)) - \(dateFormatter.string(from: toDate))")
                    .font(.title3)
                    .bold()
                    .padding(.leading, 0)
                    .padding(.trailing, 18)
            }
            
            if !chooseTimeRange { //ternary operator schöner??? Werte flippen
                closedTimeRangeSelection
            } else {
                openTimeRangeSelection
            }
            Spacer()
            SearchBar(viewModel: viewModel)
        }
        .padding(.top, 25)
        .padding(.bottom, 30)
        .fileExporter(isPresented: $presentFileExporter, documents: viewModel.getAndEmptyFilesToExport(), contentType: .data, onCompletion: {result in
            switch result {
            case .success(let url): print("data was exported to \(url)")
            case .failure(let error): print("exporting failed, \(error.localizedDescription)")
            }
        })
    }
    
    var closedTimeRangeSelection: some View {
        Group {
            Button {
                chooseTimeRange = true
            } label: {
                Text("Select time range")
                    .buttonStyled()
            }
            
            Button {
                viewModel.resetTimeRange()
                viewModel.loadPatientSummaries()
            } label: {
                Text("All data")
                    .buttonStyled()
            }
            Button {
                viewModel.loadLastSevenDays()
            } label: {
                Text("Last 7 days")
                    .buttonStyled()
            }
        }.padding(.trailing, 18)
    }
    var openTimeRangeSelection: some View {
        ZStack {
            HStack {
                Text("Select time range")
                    .font(.headline)
                    .foregroundColor(.FontPrimary)
                    .padding(.trailing, 10)
                    .onTapGesture {
                        print("Double tapped!")
                    }
                Button {
                    disableView.toggle()
                    isStartDate = true
                } label: {
                    Text("from:")
                        .buttonStyled()
                }
                Button {
                    disableView.toggle()
                    isStartDate = false
                } label: {
                    Text("to:")
                        .buttonStyled()
                }
                Button {
                    viewModel.selectedStartDate = startDate
                    viewModel.selectedEndDate = endDate
                    viewModel.loadPatientSummaries()
                    chooseTimeRange = false
                } label: {
                    Text("apply")
                        .buttonStyled()
                }
            }
            .font(Font.headline.weight(.bold))
            .labelsHidden()
        }
    }
}

struct DatePickerOverlay: View {
    @Binding var disableView: Bool
    @Binding var isStartDate: Bool
    @Binding var selectedStartDate: Date
    @Binding var selectedEndDate: Date
    
    var body: some View {
        ZStack {
            if disableView {
                Color.gray.opacity(0.5).edgesIgnoringSafeArea(.all)
                VStack {
                    if isStartDate {
                        DatePicker("", selection: $selectedStartDate, in: ...selectedEndDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()
                    } else {
                        DatePicker("", selection: $selectedEndDate, in: selectedStartDate...Date(), displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()
                    }
                    Button {
                        disableView.toggle()
                    } label: {
                        Text("Close")
                            .buttonStyled()
                    }
                }
                .frame(width: 450, height: 450, alignment: .center)
                .background(Color.primary.colorInvert())
                .cornerRadius(30)
            }
        }
    }
}

struct ContentToolbar: View {
    @State var disableView = false
    @State var enableExport = true
    @State var isStartDate = false
    @State var startDate = Date()
    @State var endDate = Date()
    
    var body: some View {
        Toolbar(viewModel: PatientsSummaryViewModel(), isStartDate: $isStartDate, disableView: $disableView, startDate: $startDate, endDate: $endDate)
    }
}

struct Toolbar_Previews: PreviewProvider {
    static var previews: some View {
        ContentToolbar()
    }
}
