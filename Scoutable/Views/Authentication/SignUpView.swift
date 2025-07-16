//
//  SignUpView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This SignUpView provides a comprehensive registration interface for the
//  Scoutable app, including role selection (Player, Coach, School Admin),
//  profile information collection, and account creation.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedRole: UserRole = .player
    @State private var sport = ""
    @State private var graduationYear = ""
    @State private var school = ""
    @State private var location = ""
    @State private var bio = ""
    @State private var showingRoleSelection = false
    @State private var currentStep = 1
    @State private var showingTerms = false
    @State private var acceptedTerms = false
    
    private let totalSteps = 3
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress indicator
                    ProgressView(value: Double(currentStep), total: Double(totalSteps))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    // Step indicator
                    HStack {
                        ForEach(1...totalSteps, id: \.self) { step in
                            Circle()
                                .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                            
                            if step < totalSteps {
                                Rectangle()
                                    .fill(step < currentStep ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(height: 2)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Step content
                    switch currentStep {
                    case 1:
                        accountDetailsStep
                    case 2:
                        profileDetailsStep
                    case 3:
                        roleSelectionStep
                    default:
                        EmptyView()
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentStep > 1 {
                        Button("Back") {
                            currentStep -= 1
                        }
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Sign Up Error", isPresented: .constant(authManager.errorMessage != nil)) {
                Button("OK") {
                    authManager.errorMessage = nil
                }
            } message: {
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                }
            }
            .sheet(isPresented: $showingTerms) {
                TermsAndConditionsView()
            }
        }
    }
    
    // MARK: - Step Views
    
    private var accountDetailsStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Account Details")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Let's start with your basic account information")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                // Email
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.headline)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                // Username
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.headline)
                    
                    TextField("Choose a username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                // Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.headline)
                    
                    SecureField("Create a password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Confirm Password
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.headline)
                    
                    SecureField("Confirm your password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding(.horizontal, 24)
            
            // Next button
            Button(action: nextStep) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canProceedToNextStep ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!canProceedToNextStep)
            .padding(.horizontal, 24)
        }
    }
    
    private var profileDetailsStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Image(systemName: "person.text.rectangle")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Profile Information")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Tell us a bit about yourself")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                // First Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(.headline)
                    
                    TextField("Enter your first name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Last Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Name")
                        .font(.headline)
                    
                    TextField("Enter your last name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Location
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.headline)
                    
                    TextField("City, State", text: $location)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Bio
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bio")
                        .font(.headline)
                    
                    TextField("Tell us about yourself", text: $bio, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
            }
            .padding(.horizontal, 24)
            
            // Navigation buttons
            HStack(spacing: 16) {
                Button("Back") {
                    currentStep -= 1
                }
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                Button(action: nextStep) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canProceedToNextStep ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canProceedToNextStep)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var roleSelectionStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                Image(systemName: "person.3.sequence")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Choose Your Role")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Select the role that best describes you")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                ForEach(UserRole.allCases, id: \.self) { role in
                    RoleSelectionCard(
                        role: role,
                        isSelected: selectedRole == role,
                        action: { selectedRole = role }
                    )
                }
            }
            .padding(.horizontal, 24)
            
            // Role-specific fields
            if selectedRole == .player {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sport")
                            .font(.headline)
                        
                        TextField("e.g., Tennis, Basketball", text: $sport)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Graduation Year")
                            .font(.headline)
                        
                        TextField("e.g., 2025", text: $graduationYear)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("School")
                            .font(.headline)
                        
                        TextField("Your current school", text: $school)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal, 24)
            } else if selectedRole == .coach || selectedRole == .schoolAdmin {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sport")
                            .font(.headline)
                        
                        TextField("e.g., Tennis, Basketball", text: $sport)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("School/Organization")
                            .font(.headline)
                        
                        TextField("Your school or organization", text: $school)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Terms and conditions
            HStack {
                Button(action: { acceptedTerms.toggle() }) {
                    HStack {
                        Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                            .foregroundColor(acceptedTerms ? .blue : .gray)
                        
                        Text("I agree to the ")
                            .foregroundColor(.secondary)
                        
                        Button("Terms & Conditions") {
                            showingTerms = true
                        }
                        .foregroundColor(.blue)
                        
                        Text(" and ")
                            .foregroundColor(.secondary)
                        
                        Button("Privacy Policy") {
                            showingTerms = true
                        }
                        .foregroundColor(.blue)
                    }
                    .font(.subheadline)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            // Navigation buttons
            HStack(spacing: 16) {
                Button("Back") {
                    currentStep -= 1
                }
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                Button(action: createAccount) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "checkmark")
                        }
                        Text(authManager.isLoading ? "Creating Account..." : "Create Account")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canCreateAccount ? Color.blue : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!canCreateAccount || authManager.isLoading)
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Computed Properties
    
    private var canProceedToNextStep: Bool {
        switch currentStep {
        case 1:
            return !email.isEmpty && !username.isEmpty && !password.isEmpty && 
                   password == confirmPassword && password.count >= 8
        case 2:
            return !firstName.isEmpty && !lastName.isEmpty
        default:
            return true
        }
    }
    
    private var canCreateAccount: Bool {
        return acceptedTerms && !firstName.isEmpty && !lastName.isEmpty
    }
    
    // MARK: - Actions
    
    private func nextStep() {
        if currentStep < totalSteps {
            currentStep += 1
        }
    }
    
    private func createAccount() {
        Task {
            await authManager.signUp(
                email: email,
                password: password,
                username: username,
                firstName: firstName,
                lastName: lastName,
                role: selectedRole,
                sport: sport.isEmpty ? nil : sport,
                graduationYear: graduationYear.isEmpty ? nil : graduationYear,
                school: school.isEmpty ? nil : school
            )
            
            if case .authenticated = authManager.authState {
                dismiss()
            }
        }
    }
}

/// Role selection card component
struct RoleSelectionCard: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: role.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : role.color)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? role.color : role.color.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(role.rawValue)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(roleDescription)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding()
            .background(isSelected ? role.color : Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? role.color : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var roleDescription: String {
        switch role {
        case .player:
            return "Athlete looking for opportunities"
        case .coach:
            return "Coach or recruiter"
        case .schoolAdmin:
            return "School administrator"
        case .admin:
            return "System administrator"
        }
    }
}

/// Terms and conditions view
struct TermsAndConditionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Terms and Conditions")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Last updated: July 2025")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Group {
                        Text("1. Acceptance of Terms")
                            .font(.headline)
                        Text("By accessing and using Scoutable, you accept and agree to be bound by the terms and provision of this agreement.")
                        
                        Text("2. User Accounts")
                            .font(.headline)
                        Text("You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.")
                        
                        Text("3. Privacy Policy")
                            .font(.headline)
                        Text("Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the Service, to understand our practices.")
                        
                        Text("4. User Conduct")
                            .font(.headline)
                        Text("You agree not to use the Service to post, upload, or otherwise transmit any content that is unlawful, harmful, threatening, abusive, harassing, defamatory, or otherwise objectionable.")
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(24)
            }
            .navigationTitle("Terms & Conditions")
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