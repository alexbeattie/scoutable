//
//  ChatListView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This ChatListView displays a list of chat conversations for the current user,
//  including direct messages and group chats, with search functionality and
//  real-time updates for new messages and unread counts.
//

import SwiftUI

struct ChatListView: View {
    @StateObject private var messagingManager = MessagingManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var searchText = ""
    @State private var showingNewChat = false
    @State private var selectedFilter: ChatFilter = .all
    
    enum ChatFilter: String, CaseIterable {
        case all = "All"
        case unread = "Unread"
        case direct = "Direct"
        case group = "Group"
        
        var icon: String {
            switch self {
            case .all: return "message"
            case .unread: return "circle.fill"
            case .direct: return "person.2"
            case .group: return "person.3"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter bar
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search conversations", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Filter buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                                                    ForEach(ChatFilter.allCases, id: \.self) { filter in
                            ChatFilterButton(
                                filter: filter,
                                isSelected: selectedFilter == filter,
                                action: { selectedFilter = filter }
                            )
                        }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                // Chat list
                if filteredChats.isEmpty {
                    emptyStateView
                } else {
                    List(filteredChats) { chat in
                        ChatRowView(chat: chat) {
                            Task {
                                await messagingManager.openChat(chat)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewChat = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingNewChat) {
                NewChatView()
            }
            .onAppear {
                if let currentUser = authManager.currentUser {
                    messagingManager.setCurrentUser(currentUser.id)
                }
            }
        }
    }
    
    private var filteredChats: [Chat] {
        var chats = messagingManager.getChats()
        
        // Apply search filter
        if !searchText.isEmpty {
            chats = chats.filter { chat in
                chat.displayName.localizedCaseInsensitiveContains(searchText) ||
                chat.lastMessage?.content.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .unread:
            chats = chats.filter { $0.unreadCount > 0 }
        case .direct:
            chats = chats.filter { !$0.isGroupChat }
        case .group:
            chats = chats.filter { $0.isGroupChat }
        }
        
        // Sort by most recent
        return chats.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "message")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Messages Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Start a conversation to connect with other users")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showingNewChat = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Start New Chat")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

/// Chat row view component
struct ChatRowView: View {
    let chat: Chat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Avatar
                ChatAvatarView(chat: chat)
                
                // Chat info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(chat.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if let lastMessage = chat.lastMessage {
                            Text(lastMessage.timestamp, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        if let lastMessage = chat.lastMessage {
                            HStack(spacing: 4) {
                                if lastMessage.messageType != .text {
                                    Image(systemName: lastMessage.messageType.icon)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(lastMessage.content)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        } else {
                            Text("No messages yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Unread count
                        if chat.unreadCount > 0 {
                            Text("\(chat.unreadCount)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(minWidth: 20, minHeight: 20)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Chat avatar view component
struct ChatAvatarView: View {
    let chat: Chat
    
    var body: some View {
        if chat.isGroupChat {
            // Group chat avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "person.3")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        } else {
            // Direct message avatar
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
    }
}

/// Chat filter button component
struct ChatFilterButton: View {
    let filter: ChatListView.ChatFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                
                Text(filter.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// New chat view
struct NewChatView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthManager.shared
    @State private var searchText = ""
    @State private var selectedUsers: Set<UUID> = []
    @State private var showingGroupSetup = false
    
    // Sample users for demo
    private let sampleUsers = [
        User(
            email: "player1@scoutable.com",
            username: "tennis_player",
            firstName: "Alex",
            lastName: "Johnson",
            role: .player,
            profileImageURL: nil,
            bio: "Tennis player looking for opportunities",
            location: "Philadelphia, PA",
            sport: "Tennis",
            graduationYear: "2025",
            school: "Penn Charter",
            isVerified: true,
            isOnline: true,
            lastSeen: Date(),
            createdAt: Date(),
            updatedAt: Date()
        ),
        User(
            email: "coach1@scoutable.com",
            username: "tennis_coach",
            firstName: "Sarah",
            lastName: "Williams",
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
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search users", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // User list
                List(filteredUsers) { user in
                    UserRowView(
                        user: user,
                        isSelected: selectedUsers.contains(user.id),
                        action: { toggleUserSelection(user.id) }
                    )
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !selectedUsers.isEmpty {
                        Button("Next") {
                            if selectedUsers.count == 1 {
                                startDirectChat()
                            } else {
                                showingGroupSetup = true
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingGroupSetup) {
                GroupSetupView(selectedUsers: Array(selectedUsers))
            }
        }
    }
    
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return sampleUsers
        } else {
            return sampleUsers.filter { user in
                user.fullName.localizedCaseInsensitiveContains(searchText) ||
                user.username.localizedCaseInsensitiveContains(searchText) ||
                user.sport?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    private func toggleUserSelection(_ userId: UUID) {
        if selectedUsers.contains(userId) {
            selectedUsers.remove(userId)
        } else {
            selectedUsers.insert(userId)
        }
    }
    
    private func startDirectChat() {
        guard let selectedUserId = selectedUsers.first else { return }
        
        Task {
            if let chat = await MessagingManager.shared.createDirectChat(with: selectedUserId) {
                await MessagingManager.shared.openChat(chat)
                dismiss()
            }
        }
    }
}

/// User row view component
struct UserRowView: View {
    let user: User
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(user.role.color.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: user.role.icon)
                        .font(.title3)
                        .foregroundColor(user.role.color)
                }
                
                // User info
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(user.fullName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if user.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                    }
                    
                    HStack {
                        Text(user.role.rawValue)
                            .font(.caption)
                            .foregroundColor(user.role.color)
                        
                        if let sport = user.sport {
                            Text("• \(sport)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let location = user.location {
                            Text("• \(location)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Group setup view
struct GroupSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var groupName = ""
    @State private var groupDescription = ""
    let selectedUsers: [UUID]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "person.3")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Create Group Chat")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Set up your group chat with \(selectedUsers.count) participants")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Group Name")
                            .font(.headline)
                        
                        TextField("Enter group name", text: $groupName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (Optional)")
                            .font(.headline)
                        
                        TextField("Enter group description", text: $groupDescription, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(2...4)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Group Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createGroupChat()
                    }
                    .disabled(groupName.isEmpty)
                }
            }
        }
    }
    
    private func createGroupChat() {
        Task {
            if let chat = await MessagingManager.shared.createGroupChat(
                name: groupName,
                participants: selectedUsers
            ) {
                await MessagingManager.shared.openChat(chat)
                dismiss()
            }
        }
    }
} 