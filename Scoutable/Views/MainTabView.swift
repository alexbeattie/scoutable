//
//  MainTabView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This is the primary navigation container for the Scoutable app after onboarding.
//  It uses a TabView to organize the main sections of the app:
//  
//  Navigation Structure:
//  - Home Feed: Social media-style feed with posts from athletes, coaches, and schools
//  - Players: Browse and filter athletes by various criteria (sport, location, stats)
//  - Coaches: Browse coaches and their school affiliations
//  - Schools: Browse educational institutions and their athletic programs
//  - Profile: User's personal profile and settings
//
//  User Flow:
//  1. User completes onboarding and selects their user type
//  2. MainTabView becomes the root navigation container
//  3. Users can switch between tabs to access different sections
//  4. Each tab may contain nested navigation for detailed views
//  5. Filtering and search is available across all sections
//
//  Design Considerations:
//  - Tab bar uses SF Symbols for consistent iconography
//  - Each tab maintains its own navigation state
//  - Filter state is shared across relevant tabs
//  - Accessibility labels are provided for screen readers
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // MARK: - Home Feed Tab
            HomeFeedView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .accessibilityLabel("Home feed with posts and updates")
            
            // MARK: - Players Tab
            PlayersListView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Players")
                }
                .accessibilityLabel("Browse and filter athletes")
            
            // MARK: - Coaches Tab
            CoachesListView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Coaches")
                }
                .accessibilityLabel("Browse coaches and schools")
            
            // MARK: - Schools Tab
            SchoolsListView()
                .tabItem {
                    Image(systemName: "building.2.fill")
                    Text("Schools")
                }
                .accessibilityLabel("Browse educational institutions")
            
            // MARK: - Profile Tab
            PlayerProfileView(player: samplePlayer)
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .accessibilityLabel("Your personal profile and settings")
        }
        .accentColor(.blue) // Primary brand color
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
