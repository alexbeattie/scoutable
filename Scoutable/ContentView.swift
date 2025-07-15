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
//struct Player:Identifiable {
//    let id = UUID()
//    let firstName: String
//    let lastName: String
//    let profileImageName: String // Name of image in Assets
//    let sport: String
//    let graduationYear: Int
//    let highSchool: String
//    let location: String
//    let utr: Double
//    let stars: Int
//    let gpa: Double
//    let videos: [String] // Could be URLs
//    let upcomingEvents: [String]
//    var fullName: String { "\(firstName) \(lastName)" }
//
//}
//struct Coach: Identifiable {
//    let id = UUID()
//    let name: String
//    let title: String
//    let school: School // <-- This should be a School object
//}
//struct School: Identifiable {
//    let id = UUID()
//    let name: String
//    let division: String
//    let conference: String
//    let players: [Player]
//    let coaches: [Coach]
//
//}



// MARK: - Sample Data
// FIX: Rewrote the sample data creation to be safer and avoid crashes.

// 1. Create Players
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

let samplePlayer3 = Player(
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

// 2. Create a temporary school instance (without coaches)
var tempPenn = School(
    name: "University of Pennsylvania",
    division: "NCAA D1",
    conference: "Ivy League",
    players: [samplePlayer, samplePlayer2],
    coaches: [] // Start with an empty array
)

// 3. Create a coach instance, now with a valid school
let sampleCoach = Coach(name: "Rich Bonfiglio", title: "Head Coach", school: tempPenn)

// 4. Create the final, fully-populated school instance
let finalPenn = School(
    name: tempPenn.name,
    division: tempPenn.division,
    conference: tempPenn.conference,
    players: tempPenn.players,
    coaches: [sampleCoach] // Now add the valid coach
)


// 5. Create sample posts
let samplePosts = [
    Post(authorName: "Aaron Sandler", authorTitle: "Student-Athlete at The Wharton School", content: "I'm excited to announce that I've committed to continue my academic and athletic journey at the University of Pennsylvania!", timestamp: "2h"),
    Post(authorName: "Rich Bonfiglio", authorTitle: "Head Coach at University of Pennsylvania", content: "Great first week of practice! The team is looking sharp and ready for the season ahead.", timestamp: "1d")
]

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
