//
//  SchoolsListView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//

import SwiftUI

struct SchoolsListView: View {
    // FIX: Ensure this line uses the 'finalPenn' constant
    let schools = [finalPenn]
    
    var body: some View {
        NavigationView {
            List(schools) { school in
                NavigationLink(destination: SchoolProfileView(school: school)) {
                    SchoolListRow(school: school)
                }
            }
            .navigationTitle("Schools")
        }
    }
}

struct SchoolListRow: View {
    let school: School
    var body: some View {
        VStack(alignment: .leading) {
            Text(school.name).font(.headline)
            Text("\(school.division) - \(school.conference)").font(.subheadline).foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
