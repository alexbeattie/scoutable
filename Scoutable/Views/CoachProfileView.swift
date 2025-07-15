//
//  CoachProfileView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//

import SwiftUI

struct CoachProfileView: View {
    let coach: Coach
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // FIX: Removed the 'player' parameter
                ProfileHeaderView(name: coach.name, title: coach.title)
                
                ProfileSection(title: "Affiliation") {
                    NavigationLink(destination: SchoolProfileView(school: coach.school)) {
                        HStack {
                            Text(coach.school.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
        .navigationTitle("Coach Profile")
    }
}
