// MARK: - Content View (App's Main Router)
/// This view acts as the initial router, deciding whether to show the onboarding flow
/// or the main application interface.
///
import SwiftUI

// MARK: - Main Entry Point
// This would be your main App struct in a real project.
// @main
// struct ScoutableApp: App {
//     var body: some Scene {
//         WindowGroup {
//             ContentView()
//         }
//     }
// }

// MARK: - Data Models (Models.swift)
/// Simple data structures to represent the core objects of the app.
/// These would be expanded to match your database schema.
struct Player {
    let id = UUID()
    let firstName: String
    let lastName: String
    let profileImageName: String // Name of image in Assets
    let sport: String
    let graduationYear: Int
    let highSchool: String
    let location: String
    let utr: Double
    let stars: Int
    let gpa: Double
    let videos: [String] // Could be URLs
    let upcomingEvents: [String]
}

// Sample data for previews
let samplePlayer = Player(
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
)

let samplePlayer2 = Player(
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
)

struct ContentView: View {
    // In a real app, this would be tied to login state (e.g., @AppStorage("isLoggedIn") var isLoggedIn = false)
    @State private var userTypeSelected = false
    
    var body: some View {
        if userTypeSelected {
            MainTabView()
        } else {
            OnboardingView(userTypeSelected: $userTypeSelected)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
