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
import Foundation

struct PlayersListView: View {
    // Sample data for the list - created directly to avoid type inference issues
    var players: [Player] {
        return [
            Player(
                firstName: "Aaron",
                lastName: "Sandler",
                profileImageName: "aaron_sandler",
                sport: "Tennis",
                graduationYear: 2025,
                highSchool: "The Wharton School",
                location: "Huntingdon Valley, PA",
                utr: 12.5,
                stars: 5,
                gpa: 4.0,
                videos: ["video1", "video2"],
                upcomingEvents: ["Boys 18s Clay Court Nationals", "Showcase at UPenn"]
            ),
            Player(
                firstName: "Stephan",
                lastName: "Gershfeld",
                profileImageName: "stephan_gershfeld",
                sport: "Tennis",
                graduationYear: 2026,
                highSchool: "Some High School",
                location: "Philadelphia, PA",
                utr: 12.8,
                stars: 5,
                gpa: 3.9,
                videos: ["video3"],
                upcomingEvents: ["NCAA Championships"]
            ),
            Player(
                firstName: "Parashar",
                lastName: "Bharadwaj",
                profileImageName: "parashar_bharadwaj",
                sport: "Tennis",
                graduationYear: 2027,
                highSchool: "Mission San Jose High",
                location: "Fremont, CA",
                utr: 11.5,
                stars: 4,
                gpa: 3.8,
                videos: [],
                upcomingEvents: ["USTA Sectionals"]
            )
        ]
    }
    @State private var searchText = ""
    @StateObject private var filterState = FilterState()
    @State private var showingFilters = false
    
    var filteredPlayers: [Player] {
        // Apply search text filter first
        let searchedPlayers = players.filter { player in
            searchText.isEmpty || player.fullName.localizedCaseInsensitiveContains(searchText)
        }
        
        // Apply advanced filters
        return searchedPlayers.filter { player in
            let utrCondition = player.utr >= filterState.minUTR && player.utr <= filterState.maxUTR
            let gradYearCondition = filterState.selectedGraduationYear == "All" || String(player.graduationYear) == filterState.selectedGraduationYear
            return utrCondition && gradYearCondition
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredPlayers) { player in
                NavigationLink(destination: PlayerProfileView(player: player)) {
                    PlayerListRow(player: player)
                }
            }
            .navigationTitle("Players")
            .searchable(text: $searchText, prompt: "Search Players")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolVariant(filterState.isFiltering ? .fill : .none)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(filters: filterState)
            }
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

