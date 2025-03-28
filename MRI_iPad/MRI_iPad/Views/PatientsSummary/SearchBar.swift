//
//  SearchBar.swift
//  DoctorsApp
//
//  Created by Patrick Witzigmann on 14.06.21.
//

import SwiftUI
 
///The Searchbar for filtering the Patients according to name, birthday, study group and aktive / inactive
struct SearchBar: View {
    @State var searchString = ""
    @ObservedObject var viewModel: PatientsSummaryViewModel
 
    @State private var isEditing = false
 
    var body: some View {
        HStack {
            TextField("Filter patients ...", text: $searchString)
                .frame(width: 300)
                .font(.headline)
                .padding(.vertical, 10)
                .padding(.horizontal, 40)
                .background(Color.BackgroundGrey)
                .accentColor(.DarkBlue)
                .cornerRadius(5)
                .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.DarkBlue, lineWidth: 2)
                    )
                ///Overlays the magnifyingglass and x button at the end of the searchbar
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.FontPrimary)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .font(.system(size: 22))
                 
                        if isEditing && !searchString.isEmpty {
                            Button(action: {
                                self.searchString = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.DarkBlue)
                                    .padding(.trailing, 14)
                            }
                        }
                    }
                )
                .padding(.horizontal, 20)
                .onTapGesture {
                    self.isEditing = true
                }
                .onChange(of: searchString) { searchString in
                    viewModel.searchPatients(searchString: searchString)
                    viewModel.setSearchPatientsString(searchString)
                }
        }
    }
}
