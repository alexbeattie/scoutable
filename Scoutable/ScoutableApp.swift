//
//  ScoutableApp.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//

import SwiftUI

@main
struct ScoutableApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch authManager.authState {
                case .notAuthenticated, .error:
                    LoginView()
                case .authenticating:
                    LoadingView()
                case .authenticated:
                    MainTabView()
                }
            }
            .environmentObject(authManager)
        }
    }
}

/// Loading view while authenticating
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Signing you in...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}
