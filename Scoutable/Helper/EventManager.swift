//
//  EventManager.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This EventManager handles all event-related functionality for the Scoutable app.
//  It provides event creation, management, RSVP handling, calendar integration,
//  and analytics tracking for tournaments, showcases, and other athletic events.
//

import SwiftUI
import EventKit

/// Manages event creation, RSVPs, calendar integration, and analytics
class EventManager: ObservableObject {
    static let shared = EventManager()
    
    @Published var events: [Event] = []
    @Published var userRSVPs: [EventRSVP] = []
    @Published var isCreatingEvent = false
    @Published var errorMessage: String?
    @Published var analytics: [EventAnalytics] = []
    
    private let eventStore = EKEventStore()
    
    private init() {
        loadSampleEvents()
        loadSampleRSVPs()
        loadSampleAnalytics()
    }
    
    // MARK: - Event Management
    
    /// Create a new event
    func createEvent(
        title: String,
        description: String,
        eventType: EventType,
        sport: String,
        location: String,
        venue: String,
        startDate: Date,
        endDate: Date,
        registrationDeadline: Date,
        maxParticipants: Int?,
        entryFee: Double?,
        organizer: String,
        organizerContact: String,
        isPublic: Bool,
        tags: [String]
    ) async {
        await MainActor.run {
            isCreatingEvent = true
            errorMessage = nil
        }
        
        let newEvent = Event(
            title: title,
            description: description,
            eventType: eventType,
            sport: sport,
            location: location,
            venue: venue,
            startDate: startDate,
            endDate: endDate,
            registrationDeadline: registrationDeadline,
            maxParticipants: maxParticipants,
            currentParticipants: 0,
            entryFee: entryFee,
            organizer: organizer,
            organizerContact: organizerContact,
            isPublic: isPublic,
            tags: tags,
            imageURL: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await MainActor.run {
            events.append(newEvent)
            isCreatingEvent = false
        }
    }
    
    /// Update an existing event
    func updateEvent(_ event: Event, updatedEvent: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = updatedEvent
        }
    }
    
    /// Delete an event
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        // Also remove associated RSVPs and analytics
        userRSVPs.removeAll { $0.eventId == event.id }
        analytics.removeAll { $0.eventId == event.id }
    }
    
    // MARK: - RSVP Management
    
    /// RSVP to an event
    func rsvpToEvent(_ event: Event, status: EventRSVP.RSVPStatus, notes: String? = nil) {
        let rsvp = EventRSVP(
            eventId: event.id,
            playerId: UUID(), // In a real app, this would be the current user's ID
            status: status,
            registeredAt: Date(),
            notes: notes,
            paymentStatus: .pending
        )
        
        // Remove existing RSVP if any
        userRSVPs.removeAll { $0.eventId == event.id }
        
        // Add new RSVP
        userRSVPs.append(rsvp)
        
        // Update event participant count
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            var updatedEvent = events[index]
            // This would need to be handled differently in a real app with proper data management
        }
    }
    
    /// Get RSVP status for an event
    func getRSVPStatus(for eventId: UUID) -> EventRSVP.RSVPStatus? {
        return userRSVPs.first { $0.eventId == eventId }?.status
    }
    
    /// Cancel RSVP for an event
    func cancelRSVP(for eventId: UUID) {
        userRSVPs.removeAll { $0.eventId == eventId }
    }
    
    // MARK: - Calendar Integration
    
    /// Request calendar access
    func requestCalendarAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            return await eventStore.requestFullAccessToEvents()
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    /// Add event to device calendar
    func addEventToCalendar(_ event: Event) async -> Bool {
        let accessGranted = await requestCalendarAccess()
        guard accessGranted else {
            await MainActor.run {
                errorMessage = "Calendar access denied"
            }
            return false
        }
        
        do {
            let ekEvent = EKEvent(eventStore: eventStore)
            ekEvent.title = event.title
            ekEvent.notes = event.description
            ekEvent.location = "\(event.venue), \(event.location)"
            ekEvent.startDate = event.startDate
            ekEvent.endDate = event.endDate
            
            // Set calendar if available
            if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
                ekEvent.calendar = defaultCalendar
            }
            
            try eventStore.save(ekEvent, span: .thisEvent)
            
            await MainActor.run {
                errorMessage = nil
            }
            return true
            
        } catch {
            await MainActor.run {
                errorMessage = "Failed to add to calendar: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    /// Remove event from device calendar
    func removeEventFromCalendar(_ event: Event) async -> Bool {
        let accessGranted = await requestCalendarAccess()
        guard accessGranted else { return false }
        
        // In a real app, you'd store the EKEvent identifier when adding to calendar
        // For now, we'll just return success
        return true
    }
    
    // MARK: - Analytics
    
    /// Track event view
    func trackEventView(_ event: Event) {
        // In a real app, this would send analytics data to a backend
        print("Event viewed: \(event.title)")
    }
    
    /// Get analytics for an event
    func getAnalytics(for eventId: UUID) -> EventAnalytics? {
        return analytics.first { $0.eventId == eventId }
    }
    
    /// Get analytics for all events
    func getAllAnalytics() -> [EventAnalytics] {
        return analytics
    }
    
    // MARK: - Filtering and Search
    
    /// Get events filtered by various criteria
    func getFilteredEvents(
        eventType: EventType? = nil,
        sport: String? = nil,
        location: String? = nil,
        dateRange: DateInterval? = nil,
        isUpcoming: Bool = false,
        searchText: String = ""
    ) -> [Event] {
        return events.filter { event in
            // Event type filter
            if let eventType = eventType, event.eventType != eventType {
                return false
            }
            
            // Sport filter
            if let sport = sport, event.sport != sport {
                return false
            }
            
            // Location filter
            if let location = location, !event.location.contains(location) {
                return false
            }
            
            // Date range filter
            if let dateRange = dateRange {
                if event.startDate < dateRange.start || event.endDate > dateRange.end {
                    return false
                }
            }
            
            // Upcoming events filter
            if isUpcoming && !event.isUpcoming {
                return false
            }
            
            // Search text filter
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                let titleMatch = event.title.lowercased().contains(searchLower)
                let descriptionMatch = event.description.lowercased().contains(searchLower)
                let locationMatch = event.location.lowercased().contains(searchLower)
                let organizerMatch = event.organizer.lowercased().contains(searchLower)
                
                if !titleMatch && !descriptionMatch && !locationMatch && !organizerMatch {
                    return false
                }
            }
            
            return true
        }
    }
    
    /// Get user's RSVP'd events
    func getUserEvents() -> [Event] {
        let userEventIds = userRSVPs.map { $0.eventId }
        return events.filter { userEventIds.contains($0.id) }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleEvents() {
        let sampleEvents = [
            Event(
                title: "USTA Boys 18s Clay Court Nationals",
                description: "The premier clay court tournament for boys 18 and under. Features top-ranked players from across the country competing for national recognition and college recruitment opportunities.",
                eventType: .tournament,
                sport: "Tennis",
                location: "Fort Lauderdale, FL",
                venue: "Veltri Tennis Center",
                startDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 35, to: Date()) ?? Date(),
                registrationDeadline: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date(),
                maxParticipants: 128,
                currentParticipants: 89,
                entryFee: 150.0,
                organizer: "USTA",
                organizerContact: "tournaments@usta.com",
                isPublic: true,
                tags: ["National", "Clay Court", "Recruitment"],
                imageURL: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Event(
                title: "Penn Tennis Showcase",
                description: "Exclusive showcase event hosted by University of Pennsylvania tennis program. Meet coaches, tour facilities, and demonstrate your skills in front of college recruiters.",
                eventType: .showcase,
                sport: "Tennis",
                location: "Philadelphia, PA",
                venue: "Penn Tennis Center",
                startDate: Calendar.current.date(byAdding: .day, value: 45, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 45, to: Date()) ?? Date(),
                registrationDeadline: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                maxParticipants: 50,
                currentParticipants: 32,
                entryFee: 75.0,
                organizer: "University of Pennsylvania",
                organizerContact: "tennis@penn.edu",
                isPublic: true,
                tags: ["Showcase", "Ivy League", "Recruitment"],
                imageURL: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Event(
                title: "Summer Tennis Camp",
                description: "Intensive summer training camp focusing on technique, strategy, and fitness. Open to players of all levels with specialized coaching for different skill groups.",
                eventType: .camp,
                sport: "Tennis",
                location: "Huntingdon Valley, PA",
                venue: "Huntingdon Valley Country Club",
                startDate: Calendar.current.date(byAdding: .day, value: 60, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 67, to: Date()) ?? Date(),
                registrationDeadline: Calendar.current.date(byAdding: .day, value: 45, to: Date()) ?? Date(),
                maxParticipants: 40,
                currentParticipants: 28,
                entryFee: 500.0,
                organizer: "Huntingdon Valley Tennis Academy",
                organizerContact: "info@hvtennis.com",
                isPublic: true,
                tags: ["Camp", "Training", "Summer"],
                imageURL: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        events = sampleEvents
    }
    
    private func loadSampleRSVPs() {
        // Sample RSVPs for the first event
        if let firstEvent = events.first {
            userRSVPs = [
                EventRSVP(
                    eventId: firstEvent.id,
                    playerId: UUID(),
                    status: .going,
                    registeredAt: Date(),
                    notes: "Looking forward to competing!",
                    paymentStatus: .paid
                )
            ]
        }
    }
    
    private func loadSampleAnalytics() {
        // Sample analytics for the first event
        if let firstEvent = events.first {
            analytics = [
                EventAnalytics(
                    eventId: firstEvent.id,
                    totalViews: 1250,
                    uniqueViews: 890,
                    rsvpCount: 89,
                    goingCount: 67,
                    maybeCount: 12,
                    notGoingCount: 8,
                    waitlistCount: 2,
                    registrationRate: 10.0, // 89/890 * 100
                    averageEngagementTime: 180.0, // 3 minutes
                    topReferrers: ["Search": 450, "Social": 320, "Direct": 280],
                    dateRange: DateInterval(start: Date(), duration: 86400 * 7) // 7 days
                )
            ]
        }
    }
} 