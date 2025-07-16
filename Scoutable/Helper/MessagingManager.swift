//
//  MessagingManager.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This MessagingManager handles all real-time messaging functionality for the
//  Scoutable app, including chat management, message sending/receiving,
//  conversation handling, and message status tracking.
//

import SwiftUI
import Combine

/// Manages real-time messaging and chat functionality
class MessagingManager: ObservableObject {
    static let shared = MessagingManager()
    
    @Published var chats: [Chat] = []
    @Published var currentChat: Chat?
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isTyping = false
    @Published var typingUsers: Set<UUID> = []
    
    private var cancellables = Set<AnyCancellable>()
    private var currentUserId: UUID?
    
    private init() {
        loadSampleData()
    }
    
    // MARK: - Chat Management
    
    /// Set current user ID for messaging
    func setCurrentUser(_ userId: UUID) {
        currentUserId = userId
    }
    
    /// Get all chats for current user
    func getChats() -> [Chat] {
        guard let currentUserId = currentUserId else { return [] }
        return chats.filter { $0.participants.contains(currentUserId) }
    }
    
    /// Create a new direct message chat
    func createDirectChat(with userId: UUID) async -> Chat? {
        guard let currentUserId = currentUserId else { return nil }
        
        // Check if chat already exists
        if let existingChat = chats.first(where: { chat in
            chat.participants.count == 2 &&
            chat.participants.contains(currentUserId) &&
            chat.participants.contains(userId) &&
            !chat.isGroupChat
        }) {
            return existingChat
        }
        
        let newChat = Chat(
            participants: [currentUserId, userId],
            lastMessage: nil,
            unreadCount: 0,
            isGroupChat: false,
            groupName: nil,
            groupImageURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await MainActor.run {
            chats.append(newChat)
        }
        
        return newChat
    }
    
    /// Create a new group chat
    func createGroupChat(
        name: String,
        participants: [UUID],
        imageURL: String? = nil
    ) async -> Chat? {
        guard let currentUserId = currentUserId else { return nil }
        
        var allParticipants = participants
        if !allParticipants.contains(currentUserId) {
            allParticipants.append(currentUserId)
        }
        
        let newChat = Chat(
            participants: allParticipants,
            lastMessage: nil,
            unreadCount: 0,
            isGroupChat: true,
            groupName: name,
            groupImageURL: imageURL,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await MainActor.run {
            chats.append(newChat)
        }
        
        return newChat
    }
    
    /// Open a chat and load messages
    func openChat(_ chat: Chat) async {
        await MainActor.run {
            currentChat = chat
            isLoading = true
        }
        
        // Load messages for this chat
        await loadMessages(for: chat.id)
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    /// Close current chat
    func closeChat() {
        currentChat = nil
        messages = []
    }
    
    // MARK: - Message Management
    
    /// Send a text message
    func sendMessage(_ content: String, in chatId: UUID) async {
        guard let currentUserId = currentUserId else { return }
        
        let message = Message(
            chatId: chatId,
            senderId: currentUserId,
            content: content,
            messageType: .text,
            status: .sending,
            timestamp: Date(),
            editedAt: nil,
            replyToMessageId: nil
        )
        
        await MainActor.run {
            messages.append(message)
        }
        
        // Simulate sending
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Update message status
        await updateMessageStatus(message.id, to: .sent)
        
        // Update chat's last message
        await updateChatLastMessage(chatId, with: message)
    }
    
    /// Send a message with attachment
    func sendMessageWithAttachment(
        content: String,
        attachment: MessageAttachment,
        in chatId: UUID
    ) async {
        guard let currentUserId = currentUserId else { return }
        
        let messageType: MessageType = {
            switch attachment.type {
            case .image: return .image
            case .video: return .video
            case .file: return .file
            case .audio: return .text // For now, treat audio as text
            }
        }()
        
        let message = Message(
            chatId: chatId,
            senderId: currentUserId,
            content: content,
            messageType: messageType,
            status: .sending,
            timestamp: Date(),
            editedAt: nil,
            replyToMessageId: nil
        )
        
        await MainActor.run {
            messages.append(message)
        }
        
        // Simulate sending with attachment
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await updateMessageStatus(message.id, to: .sent)
        await updateChatLastMessage(chatId, with: message)
    }
    
    /// Reply to a message
    func replyToMessage(_ replyToMessage: Message, with content: String, in chatId: UUID) async {
        guard let currentUserId = currentUserId else { return }
        
        let message = Message(
            chatId: chatId,
            senderId: currentUserId,
            content: content,
            messageType: .text,
            status: .sending,
            timestamp: Date(),
            editedAt: nil,
            replyToMessageId: replyToMessage.id
        )
        
        await MainActor.run {
            messages.append(message)
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        await updateMessageStatus(message.id, to: .sent)
        await updateChatLastMessage(chatId, with: message)
    }
    
    /// Edit a message
    func editMessage(_ message: Message, newContent: String) async {
        guard let currentUserId = currentUserId,
              message.senderId == currentUserId else { return }
        
        let editedMessage = Message(
            chatId: message.chatId,
            senderId: message.senderId,
            content: newContent,
            messageType: message.messageType,
            status: message.status,
            timestamp: message.timestamp,
            editedAt: Date(),
            replyToMessageId: message.replyToMessageId
        )
        
        await MainActor.run {
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index] = editedMessage
            }
        }
        
        await updateChatLastMessage(message.chatId, with: editedMessage)
    }
    
    /// Delete a message
    func deleteMessage(_ message: Message) async {
        guard let currentUserId = currentUserId,
              message.senderId == currentUserId else { return }
        
        await MainActor.run {
            messages.removeAll { $0.id == message.id }
        }
        
        // Update chat's last message if needed
        if let lastMessage = messages.last {
            await updateChatLastMessage(message.chatId, with: lastMessage)
        }
    }
    
    /// Mark messages as read
    func markMessagesAsRead(in chatId: UUID) async {
        await MainActor.run {
            for (index, message) in messages.enumerated() {
                if message.chatId == chatId && message.senderId != currentUserId {
                    var updatedMessage = message
                    updatedMessage.status = .read
                    messages[index] = updatedMessage
                }
            }
            
            // Update chat unread count
            if let chatIndex = chats.firstIndex(where: { $0.id == chatId }) {
                chats[chatIndex].unreadCount = 0
            }
        }
    }
    
    // MARK: - Typing Indicators
    
    /// Start typing indicator
    func startTyping(in chatId: UUID) {
        guard let currentUserId = currentUserId else { return }
        
        // In a real app, this would send a typing indicator to other participants
        print("User \(currentUserId) started typing in chat \(chatId)")
    }
    
    /// Stop typing indicator
    func stopTyping(in chatId: UUID) {
        guard let currentUserId = currentUserId else { return }
        
        // In a real app, this would send a stop typing indicator
        print("User \(currentUserId) stopped typing in chat \(chatId)")
    }
    
    // MARK: - Search and Filter
    
    /// Search messages in current chat
    func searchMessages(_ query: String) -> [Message] {
        guard !query.isEmpty else { return messages }
        return messages.filter { $0.content.localizedCaseInsensitiveContains(query) }
    }
    
    /// Get messages by date range
    func getMessages(from startDate: Date, to endDate: Date) -> [Message] {
        return messages.filter { message in
            message.timestamp >= startDate && message.timestamp <= endDate
        }
    }
    
    // MARK: - Private Methods
    
    private func loadMessages(for chatId: UUID) async {
        // Simulate loading messages
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let chatMessages = sampleMessages.filter { $0.chatId == chatId }
        
        await MainActor.run {
            messages = chatMessages.sorted { $0.timestamp < $1.timestamp }
        }
    }
    
    private func updateMessageStatus(_ messageId: UUID, to status: MessageStatus) async {
        await MainActor.run {
            if let index = messages.firstIndex(where: { $0.id == messageId }) {
                var updatedMessage = messages[index]
                updatedMessage.status = status
                messages[index] = updatedMessage
            }
        }
    }
    
    private func updateChatLastMessage(_ chatId: UUID, with message: Message) async {
        await MainActor.run {
            if let index = chats.firstIndex(where: { $0.id == chatId }) {
                var updatedChat = chats[index]
                updatedChat.lastMessage = message
                updatedChat.updatedAt = Date()
                chats[index] = updatedChat
            }
        }
    }
    
    private func loadSampleData() {
        let sampleChats = [
            Chat(
                participants: [UUID(), UUID()],
                lastMessage: Message(
                    chatId: UUID(),
                    senderId: UUID(),
                    content: "Hey! How's your tennis training going?",
                    messageType: .text,
                    status: .read,
                    timestamp: Date().addingTimeInterval(-3600),
                    editedAt: nil,
                    replyToMessageId: nil
                ),
                unreadCount: 0,
                isGroupChat: false,
                groupName: nil,
                groupImageURL: nil,
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date().addingTimeInterval(-3600)
            ),
            Chat(
                participants: [UUID(), UUID(), UUID()],
                lastMessage: Message(
                    chatId: UUID(),
                    senderId: UUID(),
                    content: "Great practice today everyone!",
                    messageType: .text,
                    status: .delivered,
                    timestamp: Date().addingTimeInterval(-1800),
                    editedAt: nil,
                    replyToMessageId: nil
                ),
                unreadCount: 2,
                isGroupChat: true,
                groupName: "Tennis Team",
                groupImageURL: nil,
                createdAt: Date().addingTimeInterval(-172800),
                updatedAt: Date().addingTimeInterval(-1800)
            )
        ]
        
        chats = sampleChats
    }
    
    private var sampleMessages: [Message] {
        guard let firstChat = chats.first else { return [] }
        
        return [
            Message(
                chatId: firstChat.id,
                senderId: firstChat.participants[0],
                content: "Hi! I saw your profile and wanted to connect.",
                messageType: .text,
                status: .read,
                timestamp: Date().addingTimeInterval(-7200),
                editedAt: nil,
                replyToMessageId: nil
            ),
            Message(
                chatId: firstChat.id,
                senderId: firstChat.participants[1],
                content: "Thanks for reaching out! I'm always looking to connect with other players.",
                messageType: .text,
                status: .read,
                timestamp: Date().addingTimeInterval(-5400),
                editedAt: nil,
                replyToMessageId: nil
            ),
            Message(
                chatId: firstChat.id,
                senderId: firstChat.participants[0],
                content: "How's your tennis training going?",
                messageType: .text,
                status: .read,
                timestamp: Date().addingTimeInterval(-3600),
                editedAt: nil,
                replyToMessageId: nil
            ),
            Message(
                chatId: firstChat.id,
                senderId: firstChat.participants[1],
                content: "It's going great! I've been working on my serve and backhand. How about you?",
                messageType: .text,
                status: .read,
                timestamp: Date().addingTimeInterval(-1800),
                editedAt: nil,
                replyToMessageId: nil
            )
        ]
    }
} 