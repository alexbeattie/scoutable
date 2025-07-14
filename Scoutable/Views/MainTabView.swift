//
//  MainTabView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
import SwiftUI


// MARK: - Main Application UI (MainTabView.swift)
/// The main tabbed interface for the app, similar to the navigation bar in the mockups.
struct MainTabView: View {
    var body: some View {
        TabView {
            // Home Feed (Placeholder)
            NavigationView {
                Text("Home Feed")
                    .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            // Players List View
            PlayersListView()
                .tabItem {
                    Label("Players", systemImage: "person.3.fill")
                }

            // Schools (Placeholder)
            NavigationView {
                Text("Schools List")
                    .navigationTitle("Schools")
            }
            .tabItem {
                Label("Schools", systemImage: "graduationcap.fill")
            }
            
            // My Profile (Placeholder)
            NavigationView {
                PlayerProfileView(player: samplePlayer)
                    .navigationTitle("My Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
