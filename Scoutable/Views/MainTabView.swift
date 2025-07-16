//
//  MainTabView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This is the primary navigation container for the Scoutable app after authentication.
//  It uses a TabView to organize the main sections of the app:
//  
//  Navigation Structure:
//  - Home Feed: Social media-style feed with posts from athletes, coaches, and schools
//  - Messages: Real-time messaging and chat functionality
//  - Players: Browse and filter athletes by various criteria (sport, location, stats)
//  - Events: Browse and manage events, tournaments, and camps
//  - Profile: User's personal profile and settings
//
//  User Flow:
//  1. User completes authentication and enters the main app
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
    @StateObject private var messagingManager = MessagingManager.shared
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        TabView {
            // MARK: - Home Tab
            HomeFeedView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            // MARK: - Messages Tab
            ChatListView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Messages")
                }
                .badge(messagingManager.getChats().reduce(0) { $0 + $1.unreadCount })
            
            // MARK: - Players Tab
            PlayersListView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Players")
                }
            
            // MARK: - Events Tab
            EventsListView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Events")
                }
            
            // MARK: - Profile Tab
            UserProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .onAppear {
            if let currentUser = authManager.currentUser {
                messagingManager.setCurrentUser(currentUser.id)
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
