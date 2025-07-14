//
//  PlayersListView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
// MARK: - Players List View (PlayersListView.swift)
/// A view to display a list of players, which can be filtered.
///
import SwiftUI

struct PlayersListView: View {
    // Sample data for the list
    let players = [samplePlayer, samplePlayer2]
    
    var body: some View {
        NavigationView {
            List(players, id: \.id) { player in
                NavigationLink(destination: PlayerProfileView(player: player)) {
                    PlayerListRow(player: player)
                }
            }
            .navigationTitle("Players")
            .listStyle(PlainListStyle())
        }
    }
}

/// A single row in the players list.
struct PlayerListRow: View {
    let player: Player
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "person.crop.circle.fill") // Placeholder for profile image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text("\(player.firstName) \(player.lastName)")
                    .font(.headline)
                Text(player.highSchool)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("UTR: \(String(format: "%.2f", player.utr)) | \(player.stars) Stars")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

