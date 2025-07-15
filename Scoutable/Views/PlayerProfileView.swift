//
//  PlayerProfileView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
import SwiftUI

struct PlayerProfileView: View {
    let player: Player
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // FIX: Removed the 'player' parameter from this call
                ProfileHeaderView(name: player.fullName, title: "\(player.sport) Athlete | Class of \(String(player.graduationYear))")
                
                ProfileStatsGridView(player: player)
                    .padding(.horizontal)
                
                ProfileSection(title: "Academics") {
                    InfoRow(label: "GPA", value: "\(player.gpa)")
                }
                
                ProfileSection(title: "Upcoming Events") {
                    ForEach(player.upcomingEvents, id: \.self) { event in
                        InfoRow(label: "Event", value: event)
                    }
                }
                
                ProfileSection(title: "Videos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(player.videos, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(width: 160, height: 90)
                                    .overlay(Image(systemName: "play.circle.fill").font(.largeTitle).foregroundColor(.white))
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Player Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Note: The #Preview block is a modern replacement for PreviewProvider
// It's good practice, but ensure your Xcode version supports it.
#Preview {
    PlayerProfileView(player: .init(firstName: "Alex", lastName: "Beattie", profileImageName: "", sport: "Basketball", graduationYear: 2025, highSchool: "Westwood High School", location: "Los Angeles, CA", utr: 0, stars: 5, gpa: 4.0, videos: [], upcomingEvents: []))
}
