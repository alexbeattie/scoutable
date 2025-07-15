//
//  VideoGalleryView.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This VideoGalleryView provides a comprehensive video gallery for player profiles.
//  It displays videos in a grid layout with thumbnails, metadata, and playback controls.
//  The gallery supports video management, filtering, and social features like likes and comments.
//  It integrates with the VideoManager for upload and playback functionality.
//

import SwiftUI
import AVKit

/// Video gallery view for displaying player videos
struct VideoGalleryView: View {
    let player: Player
    @StateObject private var videoManager = VideoManager.shared
    @State private var selectedVideo: VideoManager.VideoItem?
    @State private var showingVideoPlayer = false
    @State private var showingUploadView = false
    @State private var searchText = ""
    @State private var selectedFilter: VideoFilter = .all
    
    enum VideoFilter: String, CaseIterable {
        case all = "All"
        case highlights = "Highlights"
        case games = "Games"
        case training = "Training"
        case interviews = "Interviews"
    }
    
    var filteredVideos: [VideoManager.VideoItem] {
        let videos = videoManager.uploadedVideos
        
        // Filter by search text
        let searchFiltered = searchText.isEmpty ? videos : videos.filter { video in
            video.title.localizedCaseInsensitiveContains(searchText) ||
            video.description.localizedCaseInsensitiveContains(searchText) ||
            video.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Filter by category
        switch selectedFilter {
        case .all:
            return searchFiltered
        case .highlights:
            return searchFiltered.filter { $0.tags.contains("highlights") }
        case .games:
            return searchFiltered.filter { $0.tags.contains("games") }
        case .training:
            return searchFiltered.filter { $0.tags.contains("training") }
        case .interviews:
            return searchFiltered.filter { $0.tags.contains("interviews") }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with search and filters
            VStack(spacing: 12) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search videos...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                
                // Filter buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(VideoFilter.allCases, id: \.self) { filter in
                            FilterButton(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Video grid
            if filteredVideos.isEmpty {
                EmptyVideoState(
                    searchText: searchText,
                    selectedFilter: selectedFilter
                ) {
                    showingUploadView = true
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 16) {
                        ForEach(filteredVideos) { video in
                            VideoThumbnailView(video: video) {
                                selectedVideo = video
                                showingVideoPlayer = true
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Videos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingUploadView = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingVideoPlayer) {
            if let video = selectedVideo {
                VideoPlayerSheet(video: video)
            }
        }
        .sheet(isPresented: $showingUploadView) {
            VideoUploadView()
        }
    }
}

/// Video thumbnail view for grid display
struct VideoThumbnailView: View {
    let video: VideoManager.VideoItem
    let onTap: () -> Void
    @State private var showingOptions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fit)
                
                // Play button overlay
                Circle()
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    )
                
                // Duration badge
                VStack {
                    HStack {
                        Spacer()
                        Text(video.formattedDuration)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(4)
                    }
                    Spacer()
                }
                .padding(8)
            }
            .onTapGesture {
                onTap()
            }
            
            // Video info
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(video.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(video.formattedFileSize)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(video.uploadDate, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Tags
                if !video.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(video.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                            
                            if video.tags.count > 3 {
                                Text("+\(video.tags.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .contextMenu {
            Button("Play") {
                onTap()
            }
            
            Button("Edit") {
                // TODO: Implement edit functionality
            }
            
            Button("Share") {
                // TODO: Implement share functionality
            }
            
            Divider()
            
            Button("Delete", role: .destructive) {
                VideoManager.shared.deleteVideo(video)
            }
        }
    }
}

/// Filter button for video categories
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.secondary.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

/// Empty state when no videos are available
struct EmptyVideoState: View {
    let searchText: String
    let selectedFilter: VideoGalleryView.VideoFilter
    let onAddVideo: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "video.slash")
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
                Button(action: onAddVideo) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Your First Video")
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
            return "No videos found"
        } else if selectedFilter != .all {
            return "No \(selectedFilter.rawValue.lowercased()) videos"
        } else {
            return "No videos yet"
        }
    }
    
    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "Try adjusting your search terms or browse all videos"
        } else if selectedFilter != .all {
            return "Add some \(selectedFilter.rawValue.lowercased()) videos to get started"
        } else {
            return "Upload your first video to showcase your skills to coaches and scouts"
        }
    }
}

/// Full-screen video player sheet
struct VideoPlayerSheet: View {
    let video: VideoManager.VideoItem
    @Environment(\.dismiss) private var dismiss
    @State private var showingVideoDetails = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Video player
                CustomVideoPlayer(videoURL: video.videoURL)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Video details
                if showingVideoDetails {
                    VideoDetailsView(video: video)
                        .frame(height: 200)
                }
            }
            .navigationTitle(video.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingVideoDetails.toggle() }) {
                        Image(systemName: showingVideoDetails ? "chevron.down" : "chevron.up")
                    }
                }
            }
        }
    }
}

/// Video details view
struct VideoDetailsView: View {
    let video: VideoManager.VideoItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(video.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // Metadata
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details")
                        .font(.headline)
                    
                    HStack {
                        DetailItem(icon: "clock", title: "Duration", value: video.formattedDuration)
                        Spacer()
                        DetailItem(icon: "doc", title: "Size", value: video.formattedFileSize)
                        Spacer()
                        DetailItem(icon: "calendar", title: "Uploaded", value: video.uploadDate, style: .relative)
                    }
                }
                
                // Tags
                if !video.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 80))
                        ], spacing: 8) {
                            ForEach(video.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

/// Detail item for video metadata
struct DetailItem: View {
    let icon: String
    let title: String
    let value: String
    let style: Date.RelativeFormatStyle?
    
    init(icon: String, title: String, value: String, style: Date.RelativeFormatStyle? = nil) {
        self.icon = icon
        self.title = title
        self.value = value
        self.style = style
    }
    
    init(icon: String, title: String, value: Date, style: Date.RelativeFormatStyle) {
        self.icon = icon
        self.title = title
        self.value = value.formatted(style)
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
} 