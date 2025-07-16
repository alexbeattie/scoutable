//
//  UserProfileView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This UserProfileView displays the current user's profile information,
//  settings, and account management options including profile editing,
//  password changes, and account deletion.
//

import SwiftUI

struct UserProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showingEditProfile = false
    @State private var showingChangePassword = false
    @State private var showingDeleteAccount = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeader
                    
                    // Quick actions
                    quickActionsSection
                    
                    // Account settings
                    accountSettingsSection
                    
                    // App settings
                    appSettingsSection
                    
                    // Support & legal
                    supportSection
                    
                    // Sign out button
                    signOutButton
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditProfile = true
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView()
            }
            .sheet(isPresented: $showingDeleteAccount) {
                DeleteAccountView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile image
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            
            // User info
            VStack(spacing: 8) {
                HStack {
                    Text(authManager.currentUser?.fullName ?? "User")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if authManager.currentUser?.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text("@\(authManager.currentUser?.username ?? "username")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let role = authManager.currentUser?.role {
                    HStack {
                        Image(systemName: role.icon)
                            .foregroundColor(role.color)
                        Text(role.rawValue)
                            .font(.caption)
                            .foregroundColor(role.color)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(role.color.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // Bio
            if let bio = authManager.currentUser?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Stats
            HStack(spacing: 32) {
                StatItemView(title: "Posts", value: "24")
                StatItemView(title: "Following", value: "156")
                StatItemView(title: "Followers", value: "89")
            }
        }
        .padding(.top, 16)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionCard(
                    icon: "plus.circle",
                    title: "Create Post",
                    color: .blue
                ) {
                    // TODO: Navigate to create post
                }
                
                QuickActionCard(
                    icon: "calendar.badge.plus",
                    title: "Create Event",
                    color: .green
                ) {
                    // TODO: Navigate to create event
                }
                
                QuickActionCard(
                    icon: "person.2.badge.gearshape",
                    title: "Manage Team",
                    color: .orange
                ) {
                    // TODO: Navigate to team management
                }
                
                QuickActionCard(
                    icon: "chart.bar",
                    title: "View Analytics",
                    color: .purple
                ) {
                    // TODO: Navigate to analytics
                }
            }
        }
    }
    
    private var accountSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                SettingsRowView(
                    icon: "person.circle",
                    title: "Edit Profile",
                    color: .blue
                ) {
                    showingEditProfile = true
                }
                
                SettingsRowView(
                    icon: "lock",
                    title: "Change Password",
                    color: .green
                ) {
                    showingChangePassword = true
                }
                
                SettingsRowView(
                    icon: "bell",
                    title: "Notifications",
                    color: .orange
                ) {
                    // TODO: Navigate to notifications settings
                }
                
                SettingsRowView(
                    icon: "shield",
                    title: "Privacy & Security",
                    color: .red
                ) {
                    // TODO: Navigate to privacy settings
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App Settings")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                SettingsRowView(
                    icon: "gear",
                    title: "General Settings",
                    color: .gray
                ) {
                    showingSettings = true
                }
                
                SettingsRowView(
                    icon: "paintbrush",
                    title: "Appearance",
                    color: .purple
                ) {
                    // TODO: Navigate to appearance settings
                }
                
                SettingsRowView(
                    icon: "globe",
                    title: "Language",
                    color: .blue
                ) {
                    // TODO: Navigate to language settings
                }
                
                SettingsRowView(
                    icon: "arrow.up.arrow.down",
                    title: "Data & Storage",
                    color: .green
                ) {
                    // TODO: Navigate to data settings
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support & Legal")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 1) {
                SettingsRowView(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    color: .blue
                ) {
                    // TODO: Navigate to help
                }
                
                SettingsRowView(
                    icon: "envelope",
                    title: "Contact Us",
                    color: .green
                ) {
                    // TODO: Navigate to contact
                }
                
                SettingsRowView(
                    icon: "doc.text",
                    title: "Terms of Service",
                    color: .gray
                ) {
                    // TODO: Navigate to terms
                }
                
                SettingsRowView(
                    icon: "hand.raised",
                    title: "Privacy Policy",
                    color: .gray
                ) {
                    // TODO: Navigate to privacy policy
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var signOutButton: some View {
        VStack(spacing: 16) {
            Button(action: signOut) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
            
            Button(action: { showingDeleteAccount = true }) {
                Text("Delete Account")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
    }
    
    private func signOut() {
        authManager.signOut()
    }
}

/// Stat item view component
struct StatItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

/// Quick action card component
struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Settings row view component
struct SettingsRowView: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Edit profile view
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager.shared
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var bio = ""
    @State private var location = ""
    @State private var sport = ""
    @State private var graduationYear = ""
    @State private var school = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    HStack {
                        Text("First Name")
                        Spacer()
                        TextField("First name", text: $firstName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Last Name")
                        Spacer()
                        TextField("Last name", text: $lastName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Location")
                        Spacer()
                        TextField("City, State", text: $location)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Bio") {
                    TextField("Tell us about yourself", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if authManager.currentUser?.role == .player {
                    Section("Athletic Information") {
                        HStack {
                            Text("Sport")
                            Spacer()
                            TextField("e.g., Tennis", text: $sport)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Graduation Year")
                            Spacer()
                            TextField("e.g., 2025", text: $graduationYear)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Text("School")
                            Spacer()
                            TextField("Your school", text: $school)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                } else if authManager.currentUser?.role == .coach || authManager.currentUser?.role == .schoolAdmin {
                    Section("Professional Information") {
                        HStack {
                            Text("Sport")
                            Spacer()
                            TextField("e.g., Tennis", text: $sport)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("School/Organization")
                            Spacer()
                            TextField("Your organization", text: $school)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
    }
    
    private func loadCurrentProfile() {
        guard let user = authManager.currentUser else { return }
        
        firstName = user.firstName
        lastName = user.lastName
        bio = user.bio ?? ""
        location = user.location ?? ""
        sport = user.sport ?? ""
        graduationYear = user.graduationYear ?? ""
        school = user.school ?? ""
    }
    
    private func saveProfile() {
        isLoading = true
        
        Task {
            await authManager.updateProfile(
                firstName: firstName,
                lastName: lastName,
                bio: bio.isEmpty ? nil : bio,
                location: location.isEmpty ? nil : location,
                sport: sport.isEmpty ? nil : sport,
                graduationYear: graduationYear.isEmpty ? nil : graduationYear,
                school: school.isEmpty ? nil : school
            )
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
}

/// Change password view
struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager.shared
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Current Password") {
                    SecureField("Enter current password", text: $currentPassword)
                }
                
                Section("New Password") {
                    SecureField("Enter new password", text: $newPassword)
                    SecureField("Confirm new password", text: $confirmPassword)
                }
                
                Section {
                    Text("Password must be at least 8 characters long")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        changePassword()
                    }
                    .disabled(isLoading || !canSave)
                }
            }
            .alert("Password Changed", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your password has been successfully changed.")
            }
        }
    }
    
    private var canSave: Bool {
        !currentPassword.isEmpty && !newPassword.isEmpty && 
        newPassword == confirmPassword && newPassword.count >= 8
    }
    
    private func changePassword() {
        isLoading = true
        
        Task {
            let success = await authManager.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            
            await MainActor.run {
                isLoading = false
                if success {
                    showingSuccess = true
                }
            }
        }
    }
}

/// Delete account view
struct DeleteAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager.shared
    @State private var password = ""
    @State private var isLoading = false
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Delete Account")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("This action cannot be undone. All your data will be permanently deleted.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter your password to confirm")
                        .font(.headline)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: { showingConfirmation = true }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "trash")
                            }
                            Text(isLoading ? "Deleting..." : "Delete Account")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading || password.isEmpty)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding(24)
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Delete Account", isPresented: $showingConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to permanently delete your account? This action cannot be undone.")
            }
        }
    }
    
    private func deleteAccount() {
        isLoading = true
        
        Task {
            let success = await authManager.deleteAccount(password: password)
            
            await MainActor.run {
                isLoading = false
                if success {
                    dismiss()
                }
            }
        }
    }
}

/// Settings view
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushNotifications = true
    @State private var emailNotifications = true
    @State private var darkMode = false
    @State private var autoPlayVideos = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $pushNotifications)
                    Toggle("Email Notifications", isOn: $emailNotifications)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkMode)
                }
                
                Section("Media") {
                    Toggle("Auto-play Videos", isOn: $autoPlayVideos)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 