//
//  AuthManager.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This AuthManager handles all authentication and user management functionality
//  for the Scoutable app, including registration, login, social auth, and
//  role-based access control for players, coaches, and school administrators.
//

import SwiftUI
import Combine

/// Manages user authentication, registration, and user management
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var authState: AuthState = .notAuthenticated
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Check for existing session
        checkExistingSession()
    }
    
    // MARK: - Authentication Methods
    
    /// Sign up with email and password
    func signUp(
        email: String,
        password: String,
        username: String,
        firstName: String,
        lastName: String,
        role: UserRole,
        sport: String? = nil,
        graduationYear: String? = nil,
        school: String? = nil
    ) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            authState = .authenticating
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Validate input
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty,
              !firstName.isEmpty, !lastName.isEmpty else {
            await MainActor.run {
                errorMessage = "Please fill in all required fields"
                isLoading = false
                authState = .error("Validation failed")
            }
            return
        }
        
        // Check if username is available
        if await isUsernameTaken(username) {
            await MainActor.run {
                errorMessage = "Username is already taken"
                isLoading = false
                authState = .error("Username unavailable")
            }
            return
        }
        
        // Create new user
        let newUser = User(
            email: email,
            username: username,
            firstName: firstName,
            lastName: lastName,
            role: role,
            profileImageURL: nil,
            bio: nil,
            location: nil,
            sport: sport,
            graduationYear: graduationYear,
            school: school,
            isVerified: false,
            isOnline: true,
            lastSeen: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // In a real app, this would save to backend
        await MainActor.run {
            currentUser = newUser
            authState = .authenticated(newUser)
            isLoading = false
            saveUserSession(newUser)
        }
    }
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            authState = .authenticating
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            await MainActor.run {
                errorMessage = "Please enter email and password"
                isLoading = false
                authState = .error("Invalid credentials")
            }
            return
        }
        
        // Simulate authentication
        if let user = await authenticateUser(email: email, password: password) {
            await MainActor.run {
                currentUser = user
                authState = .authenticated(user)
                isLoading = false
                saveUserSession(user)
            }
        } else {
            await MainActor.run {
                errorMessage = "Invalid email or password"
                isLoading = false
                authState = .error("Authentication failed")
            }
        }
    }
    
    /// Sign in with social provider
    func signInWithProvider(_ provider: AuthProvider) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            authState = .authenticating
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Simulate social authentication
        if let user = await authenticateWithSocialProvider(provider) {
            await MainActor.run {
                currentUser = user
                authState = .authenticated(user)
                isLoading = false
                saveUserSession(user)
            }
        } else {
            await MainActor.run {
                errorMessage = "Failed to authenticate with \(provider.rawValue)"
                isLoading = false
                authState = .error("Social auth failed")
            }
        }
    }
    
    /// Sign out current user
    func signOut() {
        currentUser = nil
        authState = .notAuthenticated
        clearUserSession()
    }
    
    /// Update user profile
    func updateProfile(
        firstName: String? = nil,
        lastName: String? = nil,
        bio: String? = nil,
        location: String? = nil,
        sport: String? = nil,
        graduationYear: String? = nil,
        school: String? = nil
    ) async {
        guard let currentUser = currentUser else { return }
        
        await MainActor.run {
            isLoading = true
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let updatedUser = User(
            email: currentUser.email,
            username: currentUser.username,
            firstName: firstName ?? currentUser.firstName,
            lastName: lastName ?? currentUser.lastName,
            role: currentUser.role,
            profileImageURL: currentUser.profileImageURL,
            bio: bio ?? currentUser.bio,
            location: location ?? currentUser.location,
            sport: sport ?? currentUser.sport,
            graduationYear: graduationYear ?? currentUser.graduationYear,
            school: school ?? currentUser.school,
            isVerified: currentUser.isVerified,
            isOnline: currentUser.isOnline,
            lastSeen: Date(),
            createdAt: currentUser.createdAt,
            updatedAt: Date()
        )
        
        await MainActor.run {
            self.currentUser = updatedUser
            if case .authenticated = authState {
                authState = .authenticated(updatedUser)
            }
            isLoading = false
            saveUserSession(updatedUser)
        }
    }
    
    /// Change user password
    func changePassword(currentPassword: String, newPassword: String) async -> Bool {
        guard let currentUser = currentUser else { return false }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Simulate password validation
        if currentPassword == "password" && newPassword.count >= 8 {
            await MainActor.run {
                isLoading = false
            }
            return true
        } else {
            await MainActor.run {
                errorMessage = "Invalid current password or new password too short"
                isLoading = false
            }
            return false
        }
    }
    
    /// Delete user account
    func deleteAccount(password: String) async -> Bool {
        guard let currentUser = currentUser else { return false }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Simulate password validation
        if password == "password" {
            await MainActor.run {
                signOut()
                isLoading = false
            }
            return true
        } else {
            await MainActor.run {
                errorMessage = "Invalid password"
                isLoading = false
            }
            return false
        }
    }
    
    // MARK: - Permission Methods
    
    /// Check if current user has a specific permission
    func hasPermission(_ permission: Permission) -> Bool {
        guard let currentUser = currentUser else { return false }
        return currentUser.role.permissions.contains(permission)
    }
    
    /// Check if current user has any of the specified permissions
    func hasAnyPermission(_ permissions: [Permission]) -> Bool {
        guard let currentUser = currentUser else { return false }
        return !Set(currentUser.role.permissions).intersection(Set(permissions)).isEmpty
    }
    
    /// Check if current user has all of the specified permissions
    func hasAllPermissions(_ permissions: [Permission]) -> Bool {
        guard let currentUser = currentUser else { return false }
        return Set(permissions).isSubset(of: Set(currentUser.role.permissions))
    }
    
    // MARK: - Private Methods
    
    private func checkExistingSession() {
        // In a real app, this would check for stored credentials
        // For now, we'll simulate no existing session
        authState = .notAuthenticated
    }
    
    private func saveUserSession(_ user: User) {
        // In a real app, this would save to UserDefaults or Keychain
        print("User session saved for: \(user.email)")
    }
    
    private func clearUserSession() {
        // In a real app, this would clear stored credentials
        print("User session cleared")
    }
    
    private func isUsernameTaken(_ username: String) async -> Bool {
        // Simulate username check
        let takenUsernames = ["alex", "coach", "admin", "player"]
        return takenUsernames.contains(username.lowercased())
    }
    
    private func authenticateUser(email: String, password: String) async -> User? {
        // Simulate authentication
        if email == "player@scoutable.com" && password == "password" {
            return User(
                email: email,
                username: "player",
                firstName: "Alex",
                lastName: "Player",
                role: .player,
                profileImageURL: nil,
                bio: "Tennis player looking for college opportunities",
                location: "Philadelphia, PA",
                sport: "Tennis",
                graduationYear: "2025",
                school: "Penn Charter",
                isVerified: true,
                isOnline: true,
                lastSeen: Date(),
                createdAt: Date(),
                updatedAt: Date()
            )
        } else if email == "coach@scoutable.com" && password == "password" {
            return User(
                email: email,
                username: "coach",
                firstName: "Sarah",
                lastName: "Coach",
                role: .coach,
                profileImageURL: nil,
                bio: "Head Tennis Coach at University of Pennsylvania",
                location: "Philadelphia, PA",
                sport: "Tennis",
                graduationYear: nil,
                school: "University of Pennsylvania",
                isVerified: true,
                isOnline: true,
                lastSeen: Date(),
                createdAt: Date(),
                updatedAt: Date()
            )
        }
        return nil
    }
    
    private func authenticateWithSocialProvider(_ provider: AuthProvider) async -> User? {
        // Simulate social authentication
        return User(
            email: "social@scoutable.com",
            username: "socialuser",
            firstName: "Social",
            lastName: "User",
            role: .player,
            profileImageURL: nil,
            bio: "Signed up with \(provider.rawValue)",
            location: "New York, NY",
            sport: "Tennis",
            graduationYear: "2026",
            school: "Stuyvesant High School",
            isVerified: true,
            isOnline: true,
            lastSeen: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
} 