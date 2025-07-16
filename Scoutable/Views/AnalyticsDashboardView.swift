//
//  AnalyticsDashboardView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This AnalyticsDashboardView provides comprehensive analytics and insights
//  for events, including view metrics, RSVP rates, engagement data, and
//  performance trends for organizers and participants.
//

import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @StateObject private var eventManager = EventManager.shared
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedEvent: Event?
    @State private var showingEventPicker = false
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with time range picker
                    HeaderSection(
                        selectedTimeRange: $selectedTimeRange,
                        selectedEvent: $selectedEvent,
                        onEventPicker: { showingEventPicker = true }
                    )
                    
                    // Overview metrics
                    OverviewMetricsSection(
                        analytics: getCurrentAnalytics(),
                        timeRange: selectedTimeRange
                    )
                    
                    // RSVP breakdown chart
                    RSVPBreakdownChart(analytics: getCurrentAnalytics())
                    
                    // Engagement metrics
                    EngagementMetricsSection(analytics: getCurrentAnalytics())
                    
                    // Top performing events
                    TopEventsSection(events: eventManager.events)
                    
                    // Traffic sources
                    TrafficSourcesSection(analytics: getCurrentAnalytics())
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Export analytics
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingEventPicker) {
                EventPickerSheet(selectedEvent: $selectedEvent)
            }
        }
    }
    
    private func getCurrentAnalytics() -> [EventAnalytics] {
        if let selectedEvent = selectedEvent {
            return eventManager.getAnalytics(for: selectedEvent.id).map { [$0] } ?? []
        } else {
            return eventManager.getAllAnalytics()
        }
    }
}

/// Header section with time range picker and event selector
struct HeaderSection: View {
    @Binding var selectedTimeRange: AnalyticsDashboardView.TimeRange
    @Binding var selectedEvent: Event?
    let onEventPicker: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Time range picker
            HStack {
                Text("Time Range")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(AnalyticsDashboardView.TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Event selector
            HStack {
                Text("Event")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: onEventPicker) {
                    HStack {
                        Text(selectedEvent?.title ?? "All Events")
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Overview metrics section
struct OverviewMetricsSection: View {
    let analytics: [EventAnalytics]
    let timeRange: AnalyticsDashboardView.TimeRange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Total Views",
                    value: "\(totalViews)",
                    icon: "eye",
                    color: .blue,
                    trend: "+12%"
                )
                
                MetricCard(
                    title: "RSVP Rate",
                    value: "\(String(format: "%.1f", averageRSVPRate))%",
                    icon: "person.badge.plus",
                    color: .green,
                    trend: "+5%"
                )
                
                MetricCard(
                    title: "Avg. Engagement",
                    value: "\(String(format: "%.0f", averageEngagementTime / 60))m",
                    icon: "clock",
                    color: .orange,
                    trend: "+8%"
                )
                
                MetricCard(
                    title: "Total RSVPs",
                    value: "\(totalRSVPs)",
                    icon: "person.2",
                    color: .purple,
                    trend: "+15%"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var totalViews: Int {
        analytics.reduce(0) { $0 + $1.totalViews }
    }
    
    private var totalRSVPs: Int {
        analytics.reduce(0) { $0 + $1.rsvpCount }
    }
    
    private var averageRSVPRate: Double {
        guard !analytics.isEmpty else { return 0 }
        return analytics.reduce(0) { $0 + $1.registrationRate } / Double(analytics.count)
    }
    
    private var averageEngagementTime: TimeInterval {
        guard !analytics.isEmpty else { return 0 }
        return analytics.reduce(0) { $0 + $1.averageEngagementTime } / Double(analytics.count)
    }
}

/// Metric card component
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                Spacer()
                
                Text(trend)
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// RSVP breakdown chart
struct RSVPBreakdownChart: View {
    let analytics: [EventAnalytics]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("RSVP Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(rsvpData, id: \.status) { data in
                        SectorMark(
                            angle: .value("Count", data.count),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(data.color)
                        .annotation(position: .overlay) {
                            Text("\(data.count)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(height: 200)
            } else {
                // Fallback for older iOS versions
                VStack(spacing: 12) {
                    ForEach(rsvpData, id: \.status) { data in
                        HStack {
                            Circle()
                                .fill(data.color)
                                .frame(width: 12, height: 12)
                            
                            Text(data.status)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(data.count)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // Legend
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(rsvpData, id: \.status) { data in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(data.color)
                            .frame(width: 8, height: 8)
                        
                        Text(data.status)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var rsvpData: [RSVPChartData] {
        let goingCount = analytics.reduce(0) { $0 + $1.goingCount }
        let maybeCount = analytics.reduce(0) { $0 + $1.maybeCount }
        let notGoingCount = analytics.reduce(0) { $0 + $1.notGoingCount }
        let waitlistCount = analytics.reduce(0) { $0 + $1.waitlistCount }
        
        return [
            RSVPChartData(status: "Going", count: goingCount, color: .green),
            RSVPChartData(status: "Maybe", count: maybeCount, color: .orange),
            RSVPChartData(status: "Not Going", count: notGoingCount, color: .red),
            RSVPChartData(status: "Waitlist", count: waitlistCount, color: .yellow)
        ].filter { $0.count > 0 }
    }
}

struct RSVPChartData {
    let status: String
    let count: Int
    let color: Color
}

/// Engagement metrics section
struct EngagementMetricsSection: View {
    let analytics: [EventAnalytics]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Engagement")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                EngagementRow(
                    title: "Average Time on Page",
                    value: "\(String(format: "%.0f", averageEngagementTime / 60)) minutes",
                    icon: "clock",
                    color: .blue
                )
                
                EngagementRow(
                    title: "Bounce Rate",
                    value: "\(String(format: "%.1f", bounceRate))%",
                    icon: "arrow.up.arrow.down",
                    color: .orange
                )
                
                EngagementRow(
                    title: "Return Visitors",
                    value: "\(String(format: "%.1f", returnVisitorRate))%",
                    icon: "person.2.circle",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var averageEngagementTime: TimeInterval {
        guard !analytics.isEmpty else { return 0 }
        return analytics.reduce(0) { $0 + $1.averageEngagementTime } / Double(analytics.count)
    }
    
    private var bounceRate: Double {
        // Mock calculation - in real app this would be actual bounce rate
        return 35.2
    }
    
    private var returnVisitorRate: Double {
        // Mock calculation - in real app this would be actual return visitor rate
        return 28.7
    }
}

struct EngagementRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

/// Top performing events section
struct TopEventsSection: View {
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Performing Events")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(Array(events.prefix(5).enumerated()), id: \.element.id) { index, event in
                    HStack {
                        Text("\(index + 1)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            
                            Text(event.eventType.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let maxParticipants = event.maxParticipants {
                            Text("\(event.currentParticipants)/\(maxParticipants)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Traffic sources section
struct TrafficSourcesSection: View {
    let analytics: [EventAnalytics]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Traffic Sources")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(trafficSources, id: \.source) { data in
                    HStack {
                        Text(data.source)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(data.count)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("(\(String(format: "%.1f", data.percentage))%)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var trafficSources: [TrafficSourceData] {
        let totalViews = analytics.reduce(0) { $0 + $1.totalViews }
        guard totalViews > 0 else { return [] }
        
        var sources: [String: Int] = [:]
        for analytics in analytics {
            for (source, count) in analytics.topReferrers {
                sources[source, default: 0] += count
            }
        }
        
        return sources.map { source, count in
            TrafficSourceData(
                source: source,
                count: count,
                percentage: Double(count) / Double(totalViews) * 100
            )
        }.sorted { $0.count > $1.count }
    }
}

struct TrafficSourceData {
    let source: String
    let count: Int
    let percentage: Double
}

/// Event picker sheet
struct EventPickerSheet: View {
    @Binding var selectedEvent: Event?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var eventManager = EventManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("All Events") {
                        selectedEvent = nil
                        dismiss()
                    }
                }
                
                Section("Individual Events") {
                    ForEach(eventManager.events) { event in
                        Button {
                            selectedEvent = event
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text(event.eventType.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedEvent?.id == event.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Select Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 