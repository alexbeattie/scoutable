//
//  EventsListView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This EventsListView displays a comprehensive list of athletic events including
//  tournaments, showcases, camps, and clinics. It provides filtering, search,
//  RSVP functionality, and calendar integration for event management.
//

import SwiftUI

struct EventsListView: View {
    @StateObject private var eventManager = EventManager.shared
    @State private var searchText = ""
    @State private var selectedEventType: EventType?
    @State private var selectedSport = "All"
    @State private var showingFilters = false
    @State private var showingCreateEvent = false
    @State private var selectedFilter: EventFilter = .all
    
    enum EventFilter: String, CaseIterable {
        case all = "All Events"
        case upcoming = "Upcoming"
        case myEvents = "My Events"
        case tournaments = "Tournaments"
        case showcases = "Showcases"
        case camps = "Camps"
        
        var icon: String {
            switch self {
            case .all: return "calendar"
            case .upcoming: return "clock"
            case .myEvents: return "person.2"
            case .tournaments: return "trophy"
            case .showcases: return "star"
            case .camps: return "tent"
            }
        }
    }
    
    var filteredEvents: [Event] {
        var events = eventManager.events
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .upcoming:
            events = events.filter { $0.isUpcoming }
        case .myEvents:
            events = eventManager.getUserEvents()
        case .tournaments:
            events = events.filter { $0.eventType == .tournament }
        case .showcases:
            events = events.filter { $0.eventType == .showcase }
        case .camps:
            events = events.filter { $0.eventType == .camp }
        }
        
        // Apply search
        if !searchText.isEmpty {
            events = events.filter { event in
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.description.localizedCaseInsensitiveContains(searchText) ||
                event.location.localizedCaseInsensitiveContains(searchText) ||
                event.organizer.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by date
        return events.sorted { $0.startDate < $1.startDate }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(EventFilter.allCases, id: \.self) { filter in
                            FilterChip(
                                title: filter.rawValue,
                                icon: filter.icon,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Events list
                if filteredEvents.isEmpty {
                    EmptyEventsView(
                        searchText: searchText,
                        selectedFilter: selectedFilter,
                        onCreateEvent: { showingCreateEvent = true }
                    )
                } else {
                    List(filteredEvents) { event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            EventListRow(event: event)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Events")
            .searchable(text: $searchText, prompt: "Search Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                EventFilterView(
                    selectedEventType: $selectedEventType,
                    selectedSport: $selectedSport
                )
            }
            .sheet(isPresented: $showingCreateEvent) {
                CreateEventView()
            }
        }
    }
}

/// A single row in the events list
struct EventListRow: View {
    let event: Event
    @StateObject private var eventManager = EventManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with event type and status
            HStack {
                // Event type icon
                Image(systemName: event.eventType.icon)
                    .foregroundColor(event.eventType.color)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(event.eventType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                StatusBadge(event: event)
            }
            
            // Event details
            VStack(alignment: .leading, spacing: 8) {
                // Date and time
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text(event.formattedDateRange)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                    Text(event.formattedTime)
                        .font(.subheadline)
                }
                
                // Location
                HStack {
                    Image(systemName: "mappin.circle")
                        .foregroundColor(.secondary)
                    Text("\(event.venue), \(event.location)")
                        .font(.subheadline)
                        .lineLimit(1)
                }
                
                // Organizer and participants
                HStack {
                    Image(systemName: "person.2")
                        .foregroundColor(.secondary)
                    Text(event.organizer)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    if let maxParticipants = event.maxParticipants {
                        Text("\(event.currentParticipants)/\(maxParticipants)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Entry fee
                if let entryFee = event.entryFee {
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.secondary)
                        Text("Entry Fee: $\(String(format: "%.0f", entryFee))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Tags
            if !event.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(event.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            
            // RSVP status
            if let rsvpStatus = eventManager.getRSVPStatus(for: event.id) {
                HStack {
                    Image(systemName: rsvpStatus.icon)
                        .foregroundColor(rsvpStatus.color)
                    Text(rsvpStatus.rawValue)
                        .font(.caption)
                        .foregroundColor(rsvpStatus.color)
                    
                    Spacer()
                    
                    if event.isRegistrationOpen {
                        Text("Registration Open")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Registration Closed")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

/// Status badge for event registration and timing
struct StatusBadge: View {
    let event: Event
    
    var body: some View {
        VStack(spacing: 2) {
            if event.isPast {
                Text("Past")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.gray)
                    .cornerRadius(8)
            } else if event.isOngoing {
                Text("Live")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            } else if !event.isRegistrationOpen {
                Text("Closed")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(8)
            } else {
                Text("Open")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
        }
    }
}

/// Filter chip for event filtering
struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

/// Empty state when no events are available
struct EmptyEventsView: View {
    let searchText: String
    let selectedFilter: EventsListView.EventFilter
    let onCreateEvent: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(emptyStateTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(emptyStateMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if searchText.isEmpty && selectedFilter == .all {
                Button(action: onCreateEvent) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Create Event")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateTitle: String {
        if !searchText.isEmpty {
            return "No events found"
        } else if selectedFilter != .all {
            return "No \(selectedFilter.rawValue.lowercased())"
        } else {
            return "No events yet"
        }
    }
    
    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "Try adjusting your search terms or browse all events"
        } else if selectedFilter != .all {
            return "There are no \(selectedFilter.rawValue.lowercased()) available"
        } else {
            return "Create your first event to get started"
        }
    }
} 