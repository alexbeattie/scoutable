//
//  ProfileHeaderView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This ProfileHeaderView displays the main profile information for athletes.
//  It shows the player's photo, name, title, and key information like location and school.
//  The view supports both default avatars and custom profile images.
//  It's designed to be visually appealing and informative for coaches and scouts.
//

import SwiftUI

struct ProfileHeaderView: View {
    let name: String
    let title: String
    let player: Player
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
                    
                    // Edit button overlay
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
                    Text(name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Quick info cards
            HStack(spacing: 12) {
                InfoCard(
                    icon: "mappin.circle.fill",
                    title: "Location",
                    value: player.location,
                    color: .red
                )
                
                InfoCard(
                    icon: "graduationcap.circle.fill",
                    title: "School",
                    value: player.highSchool,
                    color: .green
                )
                
                InfoCard(
                    icon: "sportscourt.circle.fill",
                    title: "Sport",
                    value: player.sport,
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

/// Info card for displaying key player information
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Image picker for profile photos
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

/// Enhanced profile header for different user types
struct EnhancedProfileHeaderView: View {
    let player: Player
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?
    @State private var showingEditProfile = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            .overlay(
                // Profile content
                VStack(spacing: 16) {
                    // Profile image with edit capability
                    ZStack {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                )
                                .shadow(radius: 4)
                        } else {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.blue)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                )
                                .shadow(radius: 4)
                        }
                        
                        // Edit button
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: { showingImagePicker = true }) {
                                    Image(systemName: "camera.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                }
                            }
                        }
                        .offset(x: 8, y: 8)
                    }
                    
                    // Name and basic info
                    VStack(spacing: 4) {
                        Text(player.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("\(player.sport) Athlete • Class of \(player.graduationYear)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 40)
            )
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: { showingEditProfile = true }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Profile")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(20)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $profileImage)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(player: player)
        }
    }
}

/// Edit profile view
struct EditProfileView: View {
    let player: Player
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var highSchool = ""
    @State private var location = ""
    @State private var sport = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("High School", text: $highSchool)
                    TextField("Location", text: $location)
                    TextField("Sport", text: $sport)
                }
                
                Section {
                    Button("Save Changes") {
                        // TODO: Implement save functionality
                        dismiss()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
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
            }
            .onAppear {
                // Initialize form with current player data
                firstName = player.firstName
                lastName = player.lastName
                highSchool = player.highSchool
                location = player.location
                sport = player.sport
            }
        }
    }
}

#Preview {
    VStack {
        ProfileHeaderView(
            name: "Aaron Sandler",
            title: "Tennis Athlete | Class of 2025",
            player: samplePlayer
        )
        
        Divider()
        
        EnhancedProfileHeaderView(player: samplePlayer)
    }
    .padding()
}
