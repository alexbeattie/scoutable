//
//  EventFilterView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This EventFilterView provides advanced filtering options for events,
//  allowing users to filter by event type, sport, location, date range,
//  and other criteria to find relevant events.
//

import SwiftUI

struct EventFilterView: View {
    @Binding var selectedEventType: EventType?
    @Binding var selectedSport: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedLocation = "All"
    @State private var dateRange: DateRange = .all
    @State private var priceRange: PriceRange = .all
    @State private var isRegistrationOpen = false
    
    enum DateRange: String, CaseIterable {
        case all = "All Dates"
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        case quarter = "Next 3 Months"
        case year = "Next Year"
    }
    
    enum PriceRange: String, CaseIterable {
        case all = "All Prices"
        case free = "Free"
        case low = "$0 - $50"
        case medium = "$51 - $200"
        case high = "$201+"
    }
    
    let sports = ["All", "Tennis", "Basketball", "Soccer", "Baseball", "Football", "Swimming", "Track & Field"]
    let locations = ["All", "Philadelphia, PA", "New York, NY", "Los Angeles, CA", "Chicago, IL", "Miami, FL"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Type") {
                    Picker("Event Type", selection: $selectedEventType) {
                        Text("All Types").tag(nil as EventType?)
                        ForEach(EventType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type as EventType?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Sport") {
                    Picker("Sport", selection: $selectedSport) {
                        ForEach(sports, id: \.self) { sport in
                            Text(sport).tag(sport)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Location") {
                    Picker("Location", selection: $selectedLocation) {
                        ForEach(locations, id: \.self) { location in
                            Text(location).tag(location)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Date Range") {
                    Picker("Date Range", selection: $dateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Price Range") {
                    Picker("Price Range", selection: $priceRange) {
                        ForEach(PriceRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Registration") {
                    Toggle("Registration Open Only", isOn: $isRegistrationOpen)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        resetFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func resetFilters() {
        selectedEventType = nil
        selectedSport = "All"
        selectedLocation = "All"
        dateRange = .all
        priceRange = .all
        isRegistrationOpen = false
    }
} 