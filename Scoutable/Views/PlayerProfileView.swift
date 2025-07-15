//
//  PlayerProfileView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This is the main player profile view that showcases athlete information to coaches and scouts.
//  It includes comprehensive player stats, video gallery, academic information, and upcoming events.
//  The view is designed to be engaging and informative for recruitment purposes.
//  It integrates with the VideoManager for video upload and playback functionality.
//

import SwiftUI

struct PlayerProfileView: View {
    let player: Player
    @State private var selectedTab = 0
    @State private var showingVideoGallery = false
    @State private var showingContactSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Enhanced profile header
                EnhancedProfileHeaderView(player: player)
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: { showingContactSheet = true }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Contact")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    
                    Button(action: { showingVideoGallery = true }) {
                        HStack {
                            Image(systemName: "video.fill")
                            Text("Videos")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Stats overview
                ProfileStatsGridView(player: player)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                // Tabbed content
                VStack(spacing: 0) {
                    // Tab selector
                    HStack(spacing: 0) {
                        ForEach(Array(tabItems.enumerated()), id: \.offset) { index, tab in
                            Button(action: { selectedTab = index }) {
                                VStack(spacing: 4) {
                                    Image(systemName: tab.icon)
                                        .font(.title3)
                                        .foregroundColor(selectedTab == index ? .blue : .secondary)
                                    
                                    Text(tab.title)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedTab == index ? .blue : .secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Rectangle()
                                        .fill(selectedTab == index ? Color.blue.opacity(0.1) : Color.clear)
                                )
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    
                    // Tab content
                    TabView(selection: $selectedTab) {
                        // Overview tab
                        OverviewTab(player: player)
                            .tag(0)
                        
                        // Videos tab
                        VideosTab(player: player)
                            .tag(1)
                        
                        // Academics tab
                        AcademicsTab(player: player)
                            .tag(2)
                        
                        // Events tab
                        EventsTab(player: player)
                            .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 400)
                }
                .background(Color(.systemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Player Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingVideoGallery = true }) {
                        Label("View All Videos", systemImage: "video")
                    }
                    
                    Button(action: { showingContactSheet = true }) {
                        Label("Contact Player", systemImage: "message")
                    }
                    
                    Button(action: {}) {
                        Label("Share Profile", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {}) {
                        Label("Add to Favorites", systemImage: "heart")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingVideoGallery) {
            NavigationView {
                VideoGalleryView(player: player)
            }
        }
        .sheet(isPresented: $showingContactSheet) {
            ContactPlayerSheet(player: player)
        }
    }
    
    private var tabItems: [(title: String, icon: String)] {
        [
            ("Overview", "person.fill"),
            ("Videos", "video.fill"),
            ("Academics", "book.fill"),
            ("Events", "calendar.fill")
        ]
    }
}

/// Overview tab content
struct OverviewTab: View {
    let player: Player
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Key stats
                VStack(spacing: 16) {
                    Text("Key Statistics")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        StatCard(title: "UTR Rating", value: String(format: "%.1f", player.utr), icon: "chart.line.uptrend.xyaxis", color: .blue)
                        StatCard(title: "Recruiting Stars", value: "\(player.stars)", icon: "star.fill", color: .yellow)
                        StatCard(title: "GPA", value: String(format: "%.1f", player.gpa), icon: "graduationcap.fill", color: .green)
                        StatCard(title: "Grad Year", value: "\(player.graduationYear)", icon: "calendar", color: .orange)
                    }
                }
                
                // Personal info
                VStack(spacing: 16) {
                    Text("Personal Information")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        InfoRow(label: "Full Name", value: player.fullName)
                        InfoRow(label: "Sport", value: player.sport)
                        InfoRow(label: "High School", value: player.highSchool)
                        InfoRow(label: "Location", value: player.location)
                        InfoRow(label: "Graduation Year", value: "\(player.graduationYear)")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
                
                // Recent activity
                VStack(spacing: 16) {
                    Text("Recent Activity")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 8) {
                        ActivityItem(icon: "video.fill", title: "Uploaded new highlight video", time: "2 hours ago")
                        ActivityItem(icon: "star.fill", title: "Updated UTR rating", time: "1 day ago")
                        ActivityItem(icon: "calendar", title: "Added upcoming tournament", time: "3 days ago")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

/// Videos tab content
struct VideosTab: View {
    let player: Player
    @StateObject private var videoManager = VideoManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Video count and upload button
                HStack {
                    VStack(alignment: .leading) {
                        Text("Videos")
                            .font(.headline)
                        Text("\(videoManager.uploadedVideos.count) videos uploaded")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                
                // Recent videos
                if videoManager.uploadedVideos.isEmpty {
                    EmptyVideoState(
                        searchText: "",
                        selectedFilter: .all
                    ) {
                        // Add video action
                    }
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(videoManager.uploadedVideos.prefix(3)) { video in
                            VideoPreviewCard(video: video)
                        }
                    }
                }
                
                // View all videos button
                if !videoManager.uploadedVideos.isEmpty {
                    Button(action: {}) {
                        Text("View All Videos")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}

/// Academics tab content
struct AcademicsTab: View {
    let player: Player
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // GPA and academic stats
                VStack(spacing: 16) {
                    Text("Academic Performance")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        AcademicStatCard(
                            title: "GPA",
                            value: String(format: "%.2f", player.gpa),
                            subtitle: "Grade Point Average",
                            color: .green
                        )
                        
                        AcademicStatCard(
                            title: "Class Rank",
                            value: "Top 10%",
                            subtitle: "Academic Standing",
                            color: .blue
                        )
                    }
                }
                
                // Academic achievements
                VStack(spacing: 16) {
                    Text("Academic Achievements")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        AchievementItem(icon: "trophy.fill", title: "Honor Roll", description: "Maintained 4.0 GPA for 3 consecutive semesters", color: .yellow)
                        AchievementItem(icon: "book.fill", title: "AP Scholar", description: "Completed 5 Advanced Placement courses", color: .blue)
                        AchievementItem(icon: "graduationcap.fill", title: "Academic Excellence", description: "Recipient of academic merit scholarship", color: .green)
                    }
                }
                
                // Course load
                VStack(spacing: 16) {
                    Text("Current Course Load")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 8) {
                        CourseItem(name: "AP Calculus BC", grade: "A", credits: "1.0")
                        CourseItem(name: "AP Physics", grade: "A", credits: "1.0")
                        CourseItem(name: "AP Literature", grade: "A-", credits: "1.0")
                        CourseItem(name: "AP US History", grade: "A", credits: "1.0")
                        CourseItem(name: "Spanish IV", grade: "A", credits: "1.0")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

/// Events tab content
struct EventsTab: View {
    let player: Player
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Upcoming events
                VStack(spacing: 16) {
                    Text("Upcoming Events")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if player.upcomingEvents.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("No upcoming events")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Add tournaments and showcases to your calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(player.upcomingEvents, id: \.self) { event in
                                EventItem(event: event)
                            }
                        }
                    }
                }
                
                // Past events
                VStack(spacing: 16) {
                    Text("Recent Events")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        PastEventItem(
                            event: "USTA Sectionals",
                            date: "2 weeks ago",
                            result: "Quarterfinals",
                            color: .blue
                        )
                        
                        PastEventItem(
                            event: "High School State Championship",
                            date: "1 month ago",
                            result: "Runner-up",
                            color: .green
                        )
                        
                        PastEventItem(
                            event: "Regional Tournament",
                            date: "2 months ago",
                            result: "Champion",
                            color: .yellow
                        )
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views

/// Stat card for displaying key statistics
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

/// Academic stat card
struct AcademicStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

/// Achievement item
struct AchievementItem: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

/// Course item
struct CourseItem: View {
    let name: String
    let grade: String
    let credits: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
            
            Spacer()
            
            Text(grade)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
            
            Text(credits)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

/// Event item
struct EventItem: View {
    let event: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event)
                    .font(.headline)
                
                Text("Upcoming")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

/// Past event item
struct PastEventItem: View {
    let event: String
    let date: String
    let result: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event)
                    .font(.headline)
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(result)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

/// Activity item
struct ActivityItem: View {
    let icon: String
    let title: String
    let time: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

/// Video preview card
struct VideoPreviewCard: View {
    let video: VideoManager.VideoItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 80, height: 60)
                .overlay(
                    Image(systemName: "play.fill")
                        .foregroundColor(.white)
                        .font(.title3)
                )
            
            // Video info
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(video.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(video.formattedDuration)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(video.uploadDate, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

/// Contact player sheet
struct ContactPlayerSheet: View {
    let player: Player
    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Player info
                VStack(spacing: 8) {
                    Text("Contact \(player.firstName)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Send a message to this athlete")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Message form
                VStack(spacing: 16) {
                    TextField("Your message...", text: $message, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(4...8)
                    
                    Button(action: {
                        // TODO: Implement send message
                        dismiss()
                    }) {
                        Text("Send Message")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(message.isEmpty)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        PlayerProfileView(player: samplePlayer)
    }
}
