//
//  EventDetailView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This EventDetailView displays comprehensive event information including
//  details, RSVP functionality, calendar integration, and analytics for
//  tournaments, showcases, and other athletic events.
//

import SwiftUI

struct EventDetailView: View {
    let event: Event
    @StateObject private var eventManager = EventManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingRSVPSheet = false
    @State private var showingCalendarAlert = false
    @State private var calendarAlertMessage = ""
    @State private var isAddingToCalendar = false
    @State private var showingAnalytics = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                EventHeaderSection(event: event)
                
                // Action buttons
                ActionButtonsSection(
                    event: event,
                    onRSVP: { showingRSVPSheet = true },
                    onAddToCalendar: addToCalendar,
                    isAddingToCalendar: isAddingToCalendar
                )
                
                // Event details
                EventDetailsSection(event: event)
                
                // Registration info
                RegistrationSection(event: event)
                
                // Organizer info
                OrganizerSection(event: event)
                
                // Tags
                if !event.tags.isEmpty {
                    TagsSection(tags: event.tags)
                }
                
                // Analytics (if available)
                if let analytics = eventManager.getAnalytics(for: event.id) {
                    AnalyticsSection(analytics: analytics)
                }
            }
            .padding()
        }
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingAnalytics = true
                    } label: {
                        Label("Analytics", systemImage: "chart.bar")
                    }
                    
                    Button {
                        shareEvent()
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    if event.isRegistrationOpen {
                        Button {
                            showingRSVPSheet = true
                        } label: {
                            Label("RSVP", systemImage: "person.badge.plus")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingRSVPSheet) {
            RSVPSheet(event: event)
        }
        .sheet(isPresented: $showingAnalytics) {
            EventAnalyticsView(event: event)
        }
        .alert("Calendar", isPresented: $showingCalendarAlert) {
            Button("OK") { }
        } message: {
            Text(calendarAlertMessage)
        }
        .onAppear {
            eventManager.trackEventView(event)
        }
    }
    
    private func addToCalendar() {
        isAddingToCalendar = true
        
        Task {
            let success = await eventManager.addEventToCalendar(event)
            
            await MainActor.run {
                isAddingToCalendar = false
                calendarAlertMessage = success ? 
                    "Event added to your calendar successfully!" : 
                    "Failed to add event to calendar. Please check your calendar permissions."
                showingCalendarAlert = true
            }
        }
    }
    
    private func shareEvent() {
        let shareText = """
        Check out this event: \(event.title)
        
        📅 \(event.formattedDateRange)
        📍 \(event.venue), \(event.location)
        🏆 \(event.eventType.rawValue)
        
        \(event.description)
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

/// Event header section with title, type, and status
struct EventHeaderSection: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: event.eventType.icon)
                    .font(.title)
                    .foregroundColor(event.eventType.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(3)
                    
                    Text(event.eventType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(event.eventType.color)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                StatusBadge(event: event)
            }
            
            Text(event.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Action buttons section
struct ActionButtonsSection: View {
    let event: Event
    let onRSVP: () -> Void
    let onAddToCalendar: () -> Void
    let isAddingToCalendar: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if event.isRegistrationOpen {
                Button(action: onRSVP) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("RSVP Now")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            
            Button(action: onAddToCalendar) {
                HStack {
                    if isAddingToCalendar {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "calendar.badge.plus")
                    }
                    Text(isAddingToCalendar ? "Adding..." : "Add to Calendar")
                }
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            .disabled(isAddingToCalendar)
        }
    }
}

/// Event details section
struct EventDetailsSection: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Event Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DetailRow(
                    icon: "calendar",
                    title: "Date & Time",
                    value: "\(event.formattedDateRange)\n\(event.formattedTime)"
                )
                
                DetailRow(
                    icon: "mappin.circle",
                    title: "Location",
                    value: "\(event.venue)\n\(event.location)"
                )
                
                DetailRow(
                    icon: "sportscourt",
                    title: "Sport",
                    value: event.sport
                )
                
                if let entryFee = event.entryFee {
                    DetailRow(
                        icon: "dollarsign.circle",
                        title: "Entry Fee",
                        value: "$\(String(format: "%.0f", entryFee))"
                    )
                }
                
                if let maxParticipants = event.maxParticipants {
                    DetailRow(
                        icon: "person.2",
                        title: "Participants",
                        value: "\(event.currentParticipants)/\(maxParticipants)"
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Registration section
struct RegistrationSection: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Registration")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                    Text("Registration Deadline")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(event.registrationDeadline, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: event.isRegistrationOpen ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(event.isRegistrationOpen ? .green : .red)
                    Text(event.isRegistrationOpen ? "Registration Open" : "Registration Closed")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(event.isRegistrationOpen ? .green : .red)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Organizer section
struct OrganizerSection: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Organizer")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "person.circle")
                        .foregroundColor(.secondary)
                    Text(event.organizer)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.secondary)
                    Text(event.organizerContact)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("Contact") {
                        // In a real app, this would open email or messaging
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Tags section
struct TagsSection: View {
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80))
            ], spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(16)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Analytics section
struct AnalyticsSection: View {
    let analytics: EventAnalytics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analytics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Total Views")
                        .font(.subheadline)
                    Spacer()
                    Text("\(analytics.totalViews)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("RSVP Rate")
                        .font(.subheadline)
                    Spacer()
                    Text("\(String(format: "%.1f", analytics.registrationRate))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Going")
                        .font(.subheadline)
                    Spacer()
                    Text("\(analytics.goingCount)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Detail row component
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
    }
} 