//
//  Models.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This file contains the core data models for the Scoutable sports scouting app.
//  The app connects athletes, coaches, and schools through a comprehensive platform.
//  
//  Key Entities:
//  - Player: Represents athletes with stats, videos, and achievements
//  - Coach: Represents coaches with school affiliations and titles
//  - School: Represents educational institutions with athletic programs
//  - Post: Represents social media-style posts for community engagement
//  - FilterState: Manages filtering and search state across the app
//
//  Data Relationships:
//  - Schools contain multiple Players and Coaches
//  - Players have videos, upcoming events, and stats (UTR, GPA, stars)
//  - Coaches are associated with specific Schools
//  - FilterState manages search criteria across all entity types
//

import SwiftUI

// MARK: - Core Data Models

/// Represents an athlete in the scouting platform
/// Contains comprehensive information about the player's athletic and academic profile
struct Player: Identifiable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let profileImageName: String // Name of image in Assets
    let sport: String
    let graduationYear: Int
    let highSchool: String
    let location: String
    let utr: Double // Universal Tennis Rating - key metric for tennis players
    let stars: Int // Recruiting stars (1-5) - indicates talent level
    let gpa: Double // Grade Point Average - academic performance
    let videos: [String] // Video URLs or asset names for highlight reels
    let upcomingEvents: [String] // List of tournaments or events
    
    var fullName: String { "\(firstName) \(lastName)" }
}

/// Represents a coach in the scouting platform
/// Contains information about the coach's role and school affiliation
struct Coach: Identifiable {
    let id = UUID()
    let name: String
    let title: String // e.g., "Head Coach", "Assistant Coach"
    let school: School // Associated educational institution
}

/// Represents an educational institution with athletic programs
/// Contains information about the school's athletic division and programs
struct School: Identifiable {
    let id = UUID()
    let name: String
    let division: String // e.g., "NCAA D1", "NCAA D2", "NAIA"
    let conference: String // e.g., "Ivy League", "Big Ten"
    let players: [Player] // Current athletes at the school
    let coaches: [Coach] // Coaching staff
}

/// Represents social media-style posts for community engagement
/// Allows users to share updates, achievements, and announcements
struct Post: Identifiable {
    let id = UUID()
    let authorName: String
    let authorTitle: String // e.g., "Student-Athlete at The Wharton School"
    let content: String
    let timestamp: String // e.g., "2h", "1d"
}

// MARK: - Filter State Management

/// Manages the filtering and search state across the app
/// Provides centralized filtering for players, coaches, and schools
class FilterState: ObservableObject {
    @Published var selectedSport: String = "All"
    @Published var selectedLocation: String = "All"
    @Published var selectedGraduationYear: String = "All"
    @Published var selectedDivision: String = "All"
    @Published var minUTR: Double = 0.0
    @Published var maxUTR: Double = 16.0
    @Published var minStars: Int = 1
    @Published var maxStars: Int = 5
    @Published var minGPA: Double = 0.0
    @Published var maxGPA: Double = 4.0
    @Published var searchText: String = ""
    
    /// Returns true if any filters are currently active
    var isFiltering: Bool {
        return selectedSport != "All" ||
               selectedLocation != "All" ||
               selectedGraduationYear != "All" ||
               selectedDivision != "All" ||
               minUTR != 0.0 ||
               maxUTR != 16.0 ||
               minStars != 1 ||
               maxStars != 5 ||
               minGPA != 0.0 ||
               maxGPA != 4.0 ||
               !searchText.isEmpty
    }
    
    /// Resets all filters to their default values
    func resetFilters() {
        selectedSport = "All"
        selectedLocation = "All"
        selectedGraduationYear = "All"
        selectedDivision = "All"
        minUTR = 0.0
        maxUTR = 16.0
        minStars = 1
        maxStars = 5
        minGPA = 0.0
        maxGPA = 4.0
        searchText = ""
    }
    
    /// Applies filters to a list of players
    /// - Parameter players: The list of players to filter
    /// - Returns: Filtered list of players
    func filterPlayers(_ players: [Player]) -> [Player] {
        return players.filter { player in
            // Sport filter
            if selectedSport != "All" && player.sport != selectedSport {
                return false
            }
            
            // Location filter
            if selectedLocation != "All" && !player.location.contains(selectedLocation) {
                return false
            }
            
            // Graduation year filter
            if selectedGraduationYear != "All" {
                let year = Int(selectedGraduationYear) ?? 0
                if player.graduationYear != year {
                    return false
                }
            }
            
            // UTR range filter
            if player.utr < minUTR || player.utr > maxUTR {
                return false
            }
            
            // Stars range filter
            if player.stars < minStars || player.stars > maxStars {
                return false
            }
            
            // GPA range filter
            if player.gpa < minGPA || player.gpa > maxGPA {
                return false
            }
            
            // Search text filter
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                let nameMatch = player.fullName.lowercased().contains(searchLower)
                let schoolMatch = player.highSchool.lowercased().contains(searchLower)
                let locationMatch = player.location.lowercased().contains(searchLower)
                
                if !nameMatch && !schoolMatch && !locationMatch {
                    return false
                }
            }
            
            return true
        }
    }
    
    /// Applies filters to a list of coaches
    /// - Parameter coaches: The list of coaches to filter
    /// - Returns: Filtered list of coaches
    func filterCoaches(_ coaches: [Coach]) -> [Coach] {
        return coaches.filter { coach in
            // Division filter
            if selectedDivision != "All" && coach.school.division != selectedDivision {
                return false
            }
            
            // Search text filter
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                let nameMatch = coach.name.lowercased().contains(searchLower)
                let titleMatch = coach.title.lowercased().contains(searchLower)
                let schoolMatch = coach.school.name.lowercased().contains(searchLower)
                
                if !nameMatch && !titleMatch && !schoolMatch {
                    return false
                }
            }
            
            return true
        }
    }
    
    /// Applies filters to a list of schools
    /// - Parameter schools: The list of schools to filter
    /// - Returns: Filtered list of schools
    func filterSchools(_ schools: [School]) -> [School] {
        return schools.filter { school in
            // Division filter
            if selectedDivision != "All" && school.division != selectedDivision {
                return false
            }
            
            // Search text filter
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                let nameMatch = school.name.lowercased().contains(searchLower)
                let conferenceMatch = school.conference.lowercased().contains(searchLower)
                
                if !nameMatch && !conferenceMatch {
                    return false
                }
            }
            
            return true
        }
    }
}

