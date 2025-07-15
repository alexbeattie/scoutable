//
//  SchoolProfileView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
import SwiftUI

// NEW: Placeholder view for a school's profile
struct SchoolProfileView: View {
    let school: School
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack {
                    Text(school.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("\(school.division) | \(school.conference)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()

                // Coaches Section
                ProfileSection(title: "Coaches") {
                    ForEach(school.coaches) { coach in
                        NavigationLink(destination: CoachProfileView(coach: coach)) {
                            CoachListRow(coach: coach)
                                .foregroundColor(.primary) // Ensure text color is appropriate
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                // Players Section
                ProfileSection(title: "Players") {
                    ForEach(school.players) { player in
                        NavigationLink(destination: PlayerProfileView(player: player)) {
                            PlayerListRow(player: player)
                                .foregroundColor(.primary) // Ensure text color is appropriate
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("School Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
    SchoolProfileView(school: .init(name: "Test School", division: "Test Division", conference: "Test Conference", players: [], coaches: []))
}
