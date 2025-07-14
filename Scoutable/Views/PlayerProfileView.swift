//
//  PlayerProfileView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
import SwiftUI


// MARK: - Player Profile (PlayerProfileView.swift)
/// A detailed view that displays a player's profile, based on the mockups.
// MARK: - Player Profile (PlayerProfileView.swift)
/// A detailed view that displays a player's profile, based on the mockups.
struct PlayerProfileView: View {
    let player: Player
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ProfileHeaderView(player: player)
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
struct PlayerProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayerProfileView(player: samplePlayer)
        }
    }
}
