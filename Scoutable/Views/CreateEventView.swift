//
//  CreateEventView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This CreateEventView provides a comprehensive form for creating new events,
//  including all necessary fields for event details, scheduling, pricing,
//  and organizer information.
//

import SwiftUI

struct CreateEventView: View {
    @StateObject private var eventManager = EventManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedEventType: EventType = .tournament
    @State private var sport = "Tennis"
    @State private var location = ""
    @State private var venue = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600) // 1 hour later
    @State private var registrationDeadline = Date().addingTimeInterval(86400 * 7) // 1 week later
    @State private var maxParticipants: String = ""
    @State private var entryFee: String = ""
    @State private var organizer = ""
    @State private var organizerContact = ""
    @State private var isPublic = true
    @State private var tags = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    let sports = ["Tennis", "Basketball", "Soccer", "Baseball", "Football", "Swimming", "Track & Field"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Event Title", text: $title)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Event Type", selection: $selectedEventType) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Sport", selection: $sport) {
                        ForEach(sports, id: \.self) { sport in
                            Text(sport).tag(sport)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Location") {
                    TextField("Venue Name", text: $venue)
                    TextField("City, State", text: $location)
                }
                
                Section("Schedule") {
                    DatePicker("Start Date & Time", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("End Date & Time", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("Registration Deadline", selection: $registrationDeadline, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Registration") {
                    TextField("Max Participants (Optional)", text: $maxParticipants)
                        .keyboardType(.numberPad)
                    
                    TextField("Entry Fee (Optional)", text: $entryFee)
                        .keyboardType(.decimalPad)
                }
                
                Section("Organizer") {
                    TextField("Organizer Name", text: $organizer)
                    TextField("Contact Email/Phone", text: $organizerContact)
                }
                
                Section("Settings") {
                    Toggle("Public Event", isOn: $isPublic)
                    
                    TextField("Tags (comma separated)", text: $tags)
                }
                
                Section {
                    Button(action: createEvent) {
                        HStack {
                            if eventManager.isCreatingEvent {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "plus.circle.fill")
                            }
                            Text(eventManager.isCreatingEvent ? "Creating..." : "Create Event")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                    }
                    .disabled(!isFormValid || eventManager.isCreatingEvent)
                    .listRowBackground(isFormValid ? Color.blue : Color.gray)
                }
            }
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(eventManager.errorMessage != nil)) {
                Button("OK") {
                    eventManager.errorMessage = nil
                }
            } message: {
                if let errorMessage = eventManager.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !location.isEmpty &&
        !venue.isEmpty &&
        !organizer.isEmpty &&
        !organizerContact.isEmpty &&
        endDate > startDate &&
        registrationDeadline <= startDate
    }
    
    private func createEvent() {
        Task {
            await eventManager.createEvent(
                title: title,
                description: description,
                eventType: selectedEventType,
                sport: sport,
                location: location,
                venue: venue,
                startDate: startDate,
                endDate: endDate,
                registrationDeadline: registrationDeadline,
                maxParticipants: Int(maxParticipants),
                entryFee: Double(entryFee),
                organizer: organizer,
                organizerContact: organizerContact,
                isPublic: isPublic,
                tags: tags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
            )
            
            await MainActor.run {
                if eventManager.errorMessage == nil {
                    dismiss()
                }
            }
        }
    }
} 