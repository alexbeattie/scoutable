//
//  EventAnalyticsView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This EventAnalyticsView provides detailed analytics for individual events,
//  including view trends, RSVP patterns, engagement metrics, and performance
//  insights for event organizers.
//

import SwiftUI
import Charts

struct EventAnalyticsView: View {
    let event: Event
    @StateObject private var eventManager = EventManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingExportSheet = false
    
    enum TimeRange: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with event info
                    EventAnalyticsHeader(event: event)
                    
                    // Time range picker
                    TimeRangePicker(selectedTimeRange: $selectedTimeRange)
                    
                    // Key metrics
                    KeyMetricsSection(analytics: getAnalytics())
                    
                    // RSVP trends chart
                    RSVPTrendsChart(analytics: getAnalytics())
                    
                    // Engagement metrics
                    EngagementMetricsSection(analytics: getAnalytics())
                    
                    // Traffic sources
                    TrafficSourcesSection(analytics: getAnalytics())
                    
                    // Performance insights
                    PerformanceInsightsSection(event: event, analytics: getAnalytics())
                }
                .padding()
            }
            .navigationTitle("Event Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingExportSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportAnalyticsSheet(event: event)
            }
        }
    }
    
    private func getAnalytics() -> EventAnalytics? {
        return eventManager.getAnalytics(for: event.id)
    }
}

/// Event analytics header
struct EventAnalyticsHeader: View {
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
                        .lineLimit(2)
                    
                    Text(event.eventType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(event.eventType.color)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                StatusBadge(event: event)
            }
            
            Text("Analytics Overview")
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Time range picker
struct TimeRangePicker: View {
    @Binding var selectedTimeRange: EventAnalyticsView.TimeRange
    
    var body: some View {
        HStack {
            Text("Time Range")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(EventAnalyticsView.TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// Key metrics section
struct KeyMetricsSection: View {
    let analytics: EventAnalytics?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Metrics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Total Views",
                    value: "\(analytics?.totalViews ?? 0)",
                    icon: "eye",
                    color: .blue,
                    trend: "+15%"
                )
                
                MetricCard(
                    title: "Unique Views",
                    value: "\(analytics?.uniqueViews ?? 0)",
                    icon: "person.2",
                    color: .green,
                    trend: "+8%"
                )
                
                MetricCard(
                    title: "RSVP Rate",
                    value: "\(String(format: "%.1f", analytics?.registrationRate ?? 0))%",
                    icon: "person.badge.plus",
                    color: .orange,
                    trend: "+12%"
                )
                
                MetricCard(
                    title: "Avg. Time",
                    value: "\(String(format: "%.0f", (analytics?.averageEngagementTime ?? 0) / 60))m",
                    icon: "clock",
                    color: .purple,
                    trend: "+5%"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

/// RSVP trends chart
struct RSVPTrendsChart: View {
    let analytics: EventAnalytics?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("RSVP Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let analytics = analytics {
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
            } else {
                Text("No analytics data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var rsvpData: [RSVPChartData] {
        guard let analytics = analytics else { return [] }
        
        return [
            RSVPChartData(status: "Going", count: analytics.goingCount, color: .green),
            RSVPChartData(status: "Maybe", count: analytics.maybeCount, color: .orange),
            RSVPChartData(status: "Not Going", count: analytics.notGoingCount, color: .red),
            RSVPChartData(status: "Waitlist", count: analytics.waitlistCount, color: .yellow)
        ].filter { $0.count > 0 }
    }
}

/// Engagement metrics section
struct EngagementMetricsSection: View {
    let analytics: EventAnalytics?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Engagement")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                EngagementRow(
                    title: "Average Time on Page",
                    value: "\(String(format: "%.0f", (analytics?.averageEngagementTime ?? 0) / 60)) minutes",
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
    
    private var bounceRate: Double {
        // Mock calculation - in real app this would be actual bounce rate
        return 35.2
    }
    
    private var returnVisitorRate: Double {
        // Mock calculation - in real app this would be actual return visitor rate
        return 28.7
    }
}

/// Traffic sources section
struct TrafficSourcesSection: View {
    let analytics: EventAnalytics?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Traffic Sources")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let analytics = analytics {
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
            } else {
                Text("No traffic data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var trafficSources: [TrafficSourceData] {
        guard let analytics = analytics else { return [] }
        
        let totalViews = analytics.totalViews
        guard totalViews > 0 else { return [] }
        
        return analytics.topReferrers.map { source, count in
            TrafficSourceData(
                source: source,
                count: count,
                percentage: Double(count) / Double(totalViews) * 100
            )
        }.sorted { $0.count > $1.count }
    }
}

/// Performance insights section
struct PerformanceInsightsSection: View {
    let event: Event
    let analytics: EventAnalytics?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Insights")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                InsightRow(
                    title: "Registration Performance",
                    description: registrationInsight,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                InsightRow(
                    title: "Engagement Level",
                    description: engagementInsight,
                    icon: "eye",
                    color: .blue
                )
                
                InsightRow(
                    title: "Recommendations",
                    description: recommendationsInsight,
                    icon: "lightbulb",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var registrationInsight: String {
        guard let analytics = analytics else { return "No data available" }
        
        let rate = analytics.registrationRate
        if rate > 15 {
            return "Excellent registration rate! Your event is highly engaging."
        } else if rate > 10 {
            return "Good registration rate. Consider promoting more actively."
        } else {
            return "Low registration rate. Review your event description and promotion strategy."
        }
    }
    
    private var engagementInsight: String {
        guard let analytics = analytics else { return "No data available" }
        
        let time = analytics.averageEngagementTime
        if time > 300 { // 5 minutes
            return "High engagement! Visitors are spending significant time viewing your event."
        } else if time > 120 { // 2 minutes
            return "Moderate engagement. Consider adding more details or media."
        } else {
            return "Low engagement. Review your event presentation and content."
        }
    }
    
    private var recommendationsInsight: String {
        guard let analytics = analytics else { return "No data available" }
        
        var recommendations: [String] = []
        
        if analytics.registrationRate < 10 {
            recommendations.append("Increase promotion on social media")
        }
        
        if analytics.averageEngagementTime < 180 {
            recommendations.append("Add more visual content and details")
        }
        
        if analytics.goingCount < analytics.rsvpCount * 0.7 {
            recommendations.append("Follow up with 'maybe' responses")
        }
        
        if recommendations.isEmpty {
            return "Your event is performing well! Keep up the good work."
        } else {
            return recommendations.joined(separator: ", ")
        }
    }
}

/// Insight row component
struct InsightRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
    }
}

/// Export analytics sheet
struct ExportAnalyticsSheet: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Export Format") {
                    Button("PDF Report") {
                        // Export as PDF
                        dismiss()
                    }
                    
                    Button("CSV Data") {
                        // Export as CSV
                        dismiss()
                    }
                    
                    Button("Share Link") {
                        // Share analytics link
                        dismiss()
                    }
                }
                
                Section("Date Range") {
                    Button("Last 7 Days") {
                        // Export last 7 days
                        dismiss()
                    }
                    
                    Button("Last 30 Days") {
                        // Export last 30 days
                        dismiss()
                    }
                    
                    Button("All Time") {
                        // Export all time
                        dismiss()
                    }
                }
            }
            .navigationTitle("Export Analytics")
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
} 