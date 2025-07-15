//
//  CoachesListView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//

import SwiftUI

struct CoachesListView: View {
    // Note: In a real app, this data would come from a database or API.
    let coaches = [finalPenn.coaches].flatMap { $0 }
    
    var body: some View {
        NavigationView {
            List(coaches) { coach in
                NavigationLink(destination: CoachProfileView(coach: coach)) {
                    CoachListRow(coach: coach)
                }
            }
            .navigationTitle("Coaches")
        }
    }
}

struct CoachListRow: View {
    let coach: Coach
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(coach.name)
                .font(.headline)
            Text("\(coach.title) - \(coach.school.name)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
