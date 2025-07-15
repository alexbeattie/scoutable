//
//  CoachProfileView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This CoachProfileView displays coach information for the scouting platform.
//  It shows the coach's name, title, school affiliation, and other relevant details.
//  The view is designed to help athletes and other coaches connect with coaching staff.
//

import SwiftUI

struct CoachProfileView: View {
    let coach: Coach
    @State private var showingContactSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Coach profile header
                CoachProfileHeaderView(coach: coach)
                
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
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
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
                
                // Coach information sections
                VStack(spacing: 20) {
                    // School affiliation
                    ProfileSection(title: "School Affiliation") {
                        NavigationLink(destination: SchoolProfileView(school: coach.school)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(coach.school.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(coach.school.division)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
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
                    
                    // Coach details
                    ProfileSection(title: "Coach Details") {
                        VStack(spacing: 12) {
                            InfoRow(label: "Name", value: coach.name)
                            InfoRow(label: "Title", value: coach.title)
                            InfoRow(label: "School", value: coach.school.name)
                            InfoRow(label: "Division", value: coach.school.division)
                            InfoRow(label: "Conference", value: coach.school.conference)
                        }
                    }
                    
                    // Team information
                    ProfileSection(title: "Team Information") {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current Players")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("\(coach.school.players.count) athletes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(coach.school.players.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Recent activity
                    ProfileSection(title: "Recent Activity") {
                        VStack(spacing: 8) {
                            ActivityItem(icon: "person.badge.plus", title: "Added new recruit to roster", time: "2 days ago")
                            ActivityItem(icon: "calendar", title: "Scheduled campus visit", time: "1 week ago")
                            ActivityItem(icon: "message", title: "Responded to athlete inquiry", time: "1 week ago")
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Coach Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingContactSheet = true }) {
                        Label("Contact Coach", systemImage: "message")
                    }
                    
                    Button(action: {}) {
                        Label("View School Profile", systemImage: "building.2")
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
        .sheet(isPresented: $showingContactSheet) {
            ContactCoachSheet(coach: coach)
        }
    }
}

/// Coach-specific profile header view
struct CoachProfileHeaderView: View {
    let coach: Coach
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile image section
            VStack(spacing: 12) {
                // Profile image
                ZStack {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 3)
                            )
                    } else {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.blue)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 3)
                            )
                    }
                    
                    // Edit button overlay (only show if user is the coach)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: { showingImagePicker = true }) {
                                Image(systemName: "camera.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    .offset(x: 8, y: 8)
                }
                
                // Name and title
                VStack(spacing: 4) {
                    Text(coach.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(coach.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Quick info cards
            HStack(spacing: 12) {
                InfoCard(
                    icon: "building.2.circle.fill",
                    title: "School",
                    value: coach.school.name,
                    color: .blue
                )
                
                InfoCard(
                    icon: "trophy.circle.fill",
                    title: "Division",
                    value: coach.school.division,
                    color: .green
                )
                
                InfoCard(
                    icon: "person.2.circle.fill",
                    title: "Team Size",
                    value: "\(coach.school.players.count)",
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $profileImage)
        }
    }
}

/// Contact coach sheet
struct ContactCoachSheet: View {
    let coach: Coach
    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Coach info
                VStack(spacing: 8) {
                    Text("Contact \(coach.name)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(coach.title) at \(coach.school.name)")
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
            .navigationTitle("Contact Coach")
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
        CoachProfileView(coach: sampleCoach)
    }
}
