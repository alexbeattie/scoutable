//
//  RSVPSheet.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This RSVPSheet provides a comprehensive RSVP interface for events,
//  allowing users to respond with different statuses (Going, Maybe, Not Going)
//  and add notes for organizers.
//

import SwiftUI

struct RSVPSheet: View {
    let event: Event
    @StateObject private var eventManager = EventManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedStatus: EventRSVP.RSVPStatus = .going
    @State private var notes = ""
    @State private var isSubmitting = false
    @State private var showingSuccessAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Current RSVP status if any
                    if let currentStatus = eventManager.getRSVPStatus(for: event.id) {
                        HStack {
                            Image(systemName: currentStatus.icon)
                                .foregroundColor(currentStatus.color)
                            Text("Current Status: \(currentStatus.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(currentStatus.color)
                        }
                    }
                }
                
                Section("RSVP Status") {
                    ForEach(EventRSVP.RSVPStatus.allCases, id: \.self) { status in
                        HStack {
                            Button(action: {
                                selectedStatus = status
                            }) {
                                HStack {
                                    Image(systemName: status.icon)
                                        .foregroundColor(status.color)
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(status.rawValue)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text(statusDescription(for: status))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedStatus == status {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Additional Notes (Optional)") {
                    TextField("Add any notes for the organizer...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button(action: submitRSVP) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(isSubmitting ? "Submitting..." : "Submit RSVP")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                    }
                    .disabled(isSubmitting)
                    .listRowBackground(Color.blue)
                }
                
                if let currentStatus = eventManager.getRSVPStatus(for: event.id) {
                    Section {
                        Button(action: cancelRSVP) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Cancel RSVP")
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.red)
                        }
                        .listRowBackground(Color.red.opacity(0.1))
                    }
                }
            }
            .navigationTitle("RSVP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("RSVP Submitted", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your RSVP has been submitted successfully!")
        }
    }
    
    private func statusDescription(for status: EventRSVP.RSVPStatus) -> String {
        switch status {
        case .going:
            return "You will attend this event"
        case .maybe:
            return "You might attend this event"
        case .notGoing:
            return "You will not attend this event"
        case .waitlist:
            return "You're on the waitlist"
        }
    }
    
    private func submitRSVP() {
        isSubmitting = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            eventManager.rsvpToEvent(event, status: selectedStatus, notes: notes.isEmpty ? nil : notes)
            isSubmitting = false
            showingSuccessAlert = true
        }
    }
    
    private func cancelRSVP() {
        eventManager.cancelRSVP(for: event.id)
        dismiss()
    }
}

/// RSVP status badge for displaying in lists
struct RSVPStatusBadge: View {
    let status: EventRSVP.RSVPStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption)
            Text(status.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.1))
        .foregroundColor(status.color)
        .cornerRadius(8)
    }
}

/// RSVP summary view for displaying in event details
struct RSVPSummaryView: View {
    let event: Event
    @StateObject private var eventManager = EventManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RSVP Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let rsvpStatus = eventManager.getRSVPStatus(for: event.id) {
                HStack {
                    RSVPStatusBadge(status: rsvpStatus)
                    
                    Spacer()
                    
                    Button("Update") {
                        // This would show the RSVP sheet
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            } else {
                HStack {
                    Text("No RSVP yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("RSVP Now") {
                        // This would show the RSVP sheet
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