//
//  ChatDetailView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This ChatDetailView displays individual chat conversations with real-time
//  messaging functionality, including message sending, receiving, status
//  tracking, and various message types (text, images, files, etc.).
//

import SwiftUI

struct ChatDetailView: View {
    @StateObject private var messagingManager = MessagingManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var messageText = ""
    @State private var showingAttachmentPicker = false
    @State private var showingMessageOptions = false
    @State private var selectedMessage: Message?
    @State private var isTyping = false
    @State private var replyToMessage: Message?
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            chatHeader
            
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messagingManager.messages) { message in
                            MessageBubbleView(
                                message: message,
                                isFromCurrentUser: message.senderId == authManager.currentUser?.id,
                                onLongPress: { selectedMessage = message },
                                onReply: { replyToMessage = message }
                            )
                        }
                        
                        // Typing indicator
                        if isTyping {
                            TypingIndicatorView()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .onChange(of: messagingManager.messages.count) { _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(messagingManager.messages.last?.id, anchor: .bottom)
                    }
                }
                .onAppear {
                    if let lastMessage = messagingManager.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            // Reply preview
            if let replyMessage = replyToMessage {
                ReplyPreviewView(message: replyMessage) {
                    replyToMessage = nil
                }
            }
            
            // Message input
            messageInputView
        }
        .navigationBarHidden(true)
        .onAppear {
            if let currentUser = authManager.currentUser {
                messagingManager.setCurrentUser(currentUser.id)
            }
            
            // Mark messages as read
            if let currentChat = messagingManager.currentChat {
                Task {
                    await messagingManager.markMessagesAsRead(in: currentChat.id)
                }
            }
        }
        .onDisappear {
            messagingManager.closeChat()
        }
        .sheet(isPresented: $showingAttachmentPicker) {
            AttachmentPickerView { attachment in
                sendMessageWithAttachment(attachment)
            }
        }
        .actionSheet(isPresented: $showingMessageOptions) {
            ActionSheet(
                title: Text("Message Options"),
                buttons: [
                    .default(Text("Reply")) {
                        if let message = selectedMessage {
                            replyToMessage = message
                        }
                    },
                    .default(Text("Edit")) {
                        // TODO: Implement message editing
                    },
                    .destructive(Text("Delete")) {
                        if let message = selectedMessage {
                            Task {
                                await messagingManager.deleteMessage(message)
                            }
                        }
                    },
                    .cancel()
                ]
            )
        }
    }
    
    private var chatHeader: some View {
        HStack(spacing: 12) {
            // Back button
            Button(action: { messagingManager.closeChat() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // Chat info
            if let chat = messagingManager.currentChat {
                HStack(spacing: 8) {
                    ChatAvatarView(chat: chat)
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chat.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if chat.isGroupChat {
                            Text("\(chat.participants.count) members")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Online")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Spacer()
            
            // More options
            Button(action: { /* TODO: Show chat options */ }) {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray5)),
            alignment: .bottom
        )
    }
    
    private var messageInputView: some View {
        VStack(spacing: 0) {
            // Reply preview
            if let replyMessage = replyToMessage {
                ReplyPreviewView(message: replyMessage) {
                    replyToMessage = nil
                }
            }
            
            // Input area
            HStack(spacing: 12) {
                // Attachment button
                Button(action: { showingAttachmentPicker = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                // Message text field
                HStack(spacing: 8) {
                    TextField("Type a message...", text: $messageText, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .lineLimit(1...4)
                        .onChange(of: messageText) { _ in
                            handleTyping()
                        }
                    
                    if !messageText.isEmpty {
                        Button(action: { messageText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                
                // Send button
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray5)),
                alignment: .top
            )
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let currentChat = messagingManager.currentChat else { return }
        
        let messageContent = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        
        Task {
            if let replyMessage = replyToMessage {
                await messagingManager.replyToMessage(replyMessage, with: messageContent, in: currentChat.id)
                replyToMessage = nil
            } else {
                await messagingManager.sendMessage(messageContent, in: currentChat.id)
            }
        }
    }
    
    private func sendMessageWithAttachment(_ attachment: MessageAttachment) {
        guard let currentChat = messagingManager.currentChat else { return }
        
        Task {
            await messagingManager.sendMessageWithAttachment(
                content: messageText,
                attachment: attachment,
                in: currentChat.id
            )
            messageText = ""
        }
    }
    
    private func handleTyping() {
        guard let currentChat = messagingManager.currentChat else { return }
        
        if !messageText.isEmpty && !isTyping {
            isTyping = true
            messagingManager.startTyping(in: currentChat.id)
        } else if messageText.isEmpty && isTyping {
            isTyping = false
            messagingManager.stopTyping(in: currentChat.id)
        }
    }
}

/// Message bubble view component
struct MessageBubbleView: View {
    let message: Message
    let isFromCurrentUser: Bool
    let onLongPress: () -> Void
    let onReply: () -> Void
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Reply preview
                if let replyToMessageId = message.replyToMessageId {
                    ReplyPreviewView(message: Message(
                        chatId: message.chatId,
                        senderId: UUID(),
                        content: "Original message",
                        messageType: .text,
                        status: .read,
                        timestamp: Date(),
                        editedAt: nil,
                        replyToMessageId: nil
                    )) {
                        // Handle reply tap
                    }
                    .scaleEffect(0.9)
                }
                
                // Message content
                HStack(alignment: .bottom, spacing: 4) {
                    if !isFromCurrentUser {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sender Name")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 2) {
                        // Message content
                        switch message.messageType {
                        case .text:
                            Text(message.content)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isFromCurrentUser ? Color.blue : Color(.systemGray5))
                                .foregroundColor(isFromCurrentUser ? .white : .primary)
                                .cornerRadius(16)
                        case .image:
                            ImageMessageView(content: message.content)
                        case .video:
                            VideoMessageView(content: message.content)
                        case .file:
                            FileMessageView(content: message.content)
                        case .location:
                            LocationMessageView(content: message.content)
                        case .event:
                            EventMessageView(content: message.content)
                        case .profile:
                            ProfileMessageView(content: message.content)
                        }
                        
                        // Message metadata
                        HStack(spacing: 4) {
                            Text(message.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            if message.isEdited {
                                Text("(edited)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            if isFromCurrentUser {
                                Image(systemName: message.status.icon)
                                    .font(.caption2)
                                    .foregroundColor(message.status.color)
                            }
                        }
                    }
                }
            }
            .onLongPressGesture {
                onLongPress()
            }
            
            if !isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
}

/// Reply preview view component
struct ReplyPreviewView: View {
    let message: Message
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Replying to message")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(message.content)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}

/// Typing indicator view
struct TypingIndicatorView: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(1.0 + animationOffset)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationOffset
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
        .cornerRadius(16)
        .onAppear {
            animationOffset = 0.3
        }
    }
}

/// Message type views
struct ImageMessageView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(.blue)
                .frame(width: 120, height: 120)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            Text(content)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct VideoMessageView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Image(systemName: "video")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                    .frame(width: 120, height: 120)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
            
            Text(content)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FileMessageView: View {
    let content: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Document")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(content)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "arrow.down.circle")
                .foregroundColor(.blue)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LocationMessageView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "location.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)
                .frame(width: 120, height: 80)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            
            Text(content)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EventMessageView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.orange)
                
                Text("Event")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Text(content)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ProfileMessageView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle")
                    .foregroundColor(.purple)
                
                Text("Profile")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Text(content)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// Attachment picker view
struct AttachmentPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (MessageAttachment) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Add Attachment")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose what you'd like to share")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    AttachmentOptionView(
                        icon: "photo",
                        title: "Photo",
                        color: .blue
                    ) {
                        selectAttachment(.image)
                    }
                    
                    AttachmentOptionView(
                        icon: "video",
                        title: "Video",
                        color: .red
                    ) {
                        selectAttachment(.video)
                    }
                    
                    AttachmentOptionView(
                        icon: "doc",
                        title: "Document",
                        color: .green
                    ) {
                        selectAttachment(.file)
                    }
                    
                    AttachmentOptionView(
                        icon: "location",
                        title: "Location",
                        color: .orange
                    ) {
                        selectAttachment(.image) // Using image for location preview
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Attachment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func selectAttachment(_ type: MessageAttachment.AttachmentType) {
        let attachment = MessageAttachment(
            messageId: UUID(),
            type: type,
            url: "sample_url",
            filename: "sample_file",
            size: 1024,
            thumbnailURL: nil
        )
        
        onSelect(attachment)
        dismiss()
    }
}

/// Attachment option view component
struct AttachmentOptionView: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                    .frame(width: 60, height: 60)
                    .background(color.opacity(0.1))
                    .cornerRadius(12)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 