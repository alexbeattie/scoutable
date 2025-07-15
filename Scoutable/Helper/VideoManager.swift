//
//  VideoManager.swift
//  Scoutable
//
//  Created by Alex Beattie on 7/14/25.
//
//  AI Cursor Context:
//  This VideoManager handles all video-related functionality for the Scoutable app.
//  It provides video upload, storage, playback, and management capabilities.
//  The manager supports multiple video formats, compression, and cloud storage.
//  It integrates with the player profile system for highlight reels and game footage.
//

import SwiftUI
import PhotosUI
import AVKit

/// Manages video upload, storage, and playback functionality
class VideoManager: ObservableObject {
    static let shared = VideoManager()
    
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0.0
    @Published var uploadedVideos: [VideoItem] = []
    @Published var currentVideo: VideoItem?
    @Published var errorMessage: String?
    
    private init() {}
    
    /// Represents a video item with metadata
    struct VideoItem: Identifiable, Codable {
        let id = UUID()
        let title: String
        let description: String
        let fileName: String
        let fileSize: Int64
        let duration: TimeInterval
        let thumbnailURL: URL?
        let videoURL: URL
        let uploadDate: Date
        let tags: [String]
        var isPublic: Bool = true
        
        var formattedDuration: String {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
        
        var formattedFileSize: String {
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useMB, .useGB]
            formatter.countStyle = .file
            return formatter.string(fromByteCount: fileSize)
        }
    }
    
    /// Upload a video from PhotosPicker
    func uploadVideo(from item: PhotosPickerItem, title: String, description: String, tags: [String] = []) async {
        await MainActor.run {
            isUploading = true
            uploadProgress = 0.0
            errorMessage = nil
        }
        
        do {
            // Load video data
            guard let videoData = try await item.loadTransferable(type: Data.self) else {
                throw VideoError.loadFailed
            }
            
            // Validate file size (500MB limit)
            if videoData.count > 500 * 1024 * 1024 {
                throw VideoError.fileTooLarge
            }
            
            // Generate unique filename
            let fileName = "\(UUID().uuidString).mov"
            
            // Simulate upload progress
            for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
                await MainActor.run {
                    uploadProgress = progress
                }
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            }
            
            // Create video item
            let videoItem = VideoItem(
                title: title,
                description: description,
                fileName: fileName,
                fileSize: Int64(videoData.count),
                duration: 120.0, // Mock duration - would be extracted from video
                thumbnailURL: nil, // Would be generated from video
                videoURL: URL(string: "file://\(fileName)")!, // Mock URL
                uploadDate: Date(),
                tags: tags
            )
            
            await MainActor.run {
                uploadedVideos.append(videoItem)
                isUploading = false
                uploadProgress = 1.0
            }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isUploading = false
                uploadProgress = 0.0
            }
        }
    }
    
    /// Delete a video
    func deleteVideo(_ video: VideoItem) {
        uploadedVideos.removeAll { $0.id == video.id }
        if currentVideo?.id == video.id {
            currentVideo = nil
        }
    }
    
    /// Update video metadata
    func updateVideo(_ video: VideoItem, title: String, description: String, tags: [String], isPublic: Bool) {
        if let index = uploadedVideos.firstIndex(where: { $0.id == video.id }) {
            let updatedVideo = VideoItem(
                title: title,
                description: description,
                fileName: video.fileName,
                fileSize: video.fileSize,
                duration: video.duration,
                thumbnailURL: video.thumbnailURL,
                videoURL: video.videoURL,
                uploadDate: video.uploadDate,
                tags: tags,
                isPublic: isPublic
            )
            uploadedVideos[index] = updatedVideo
        }
    }
    
    /// Get videos by tags
    func getVideosByTags(_ tags: [String]) -> [VideoItem] {
        return uploadedVideos.filter { video in
            !Set(video.tags).isDisjoint(with: Set(tags))
        }
    }
    
    /// Get public videos
    func getPublicVideos() -> [VideoItem] {
        return uploadedVideos.filter { $0.isPublic }
    }
}

/// Video-related errors
enum VideoError: LocalizedError {
    case loadFailed
    case fileTooLarge
    case invalidFormat
    case uploadFailed
    case compressionFailed
    
    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "Failed to load video from device"
        case .fileTooLarge:
            return "Video file is too large (max 500MB)"
        case .invalidFormat:
            return "Video format not supported"
        case .uploadFailed:
            return "Failed to upload video"
        case .compressionFailed:
            return "Failed to compress video"
        }
    }
}

/// Video player view with custom controls
struct CustomVideoPlayer: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    
    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(12)
                    .onAppear {
                        setupPlayer()
                    }
                    .onDisappear {
                        player.pause()
                    }
                
                // Custom controls
                HStack {
                    Button(action: {
                        if isPlaying {
                            player.pause()
                        } else {
                            player.play()
                        }
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    
                    Slider(value: Binding(
                        get: { currentTime },
                        set: { newValue in
                            currentTime = newValue
                            player.seek(to: CMTime(seconds: newValue, preferredTimescale: 1))
                        }
                    ), in: 0...duration)
                    
                    Text(timeString(from: currentTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    )
            }
        }
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        
        // Get video duration
        let asset = AVAsset(url: videoURL)
        Task {
            let duration = try await asset.load(.duration)
            await MainActor.run {
                self.duration = CMTimeGetSeconds(duration)
            }
        }
        
        // Monitor playback time
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = CMTimeGetSeconds(time)
        }
    }
    
    private func timeString(from seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// Video upload view with PhotosPicker
struct VideoUploadView: View {
    @StateObject private var videoManager = VideoManager.shared
    @State private var selectedItem: PhotosPickerItem?
    @State private var title = ""
    @State private var description = ""
    @State private var tags = ""
    @State private var showingUploadSheet = false
    
    var body: some View {
        VStack {
            if videoManager.isUploading {
                VStack {
                    ProgressView(value: videoManager.uploadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding()
                    
                    Text("Uploading video... \(Int(videoManager.uploadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                PhotosPicker(selection: $selectedItem, matching: .videos) {
                    VStack {
                        Image(systemName: "video.badge.plus")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        Text("Add Video")
                            .font(.headline)
                        
                        Text("Select a video from your library")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                }
                .onChange(of: selectedItem) { item in
                    if let item = item {
                        showingUploadSheet = true
                    }
                }
            }
            
            if let errorMessage = videoManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
        }
        .sheet(isPresented: $showingUploadSheet) {
            VideoUploadSheet(
                selectedItem: selectedItem,
                title: $title,
                description: $description,
                tags: $tags
            )
        }
    }
}

/// Video upload sheet for metadata input
struct VideoUploadSheet: View {
    let selectedItem: PhotosPickerItem?
    @Binding var title: String
    @Binding var description: String
    @Binding var tags: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var videoManager = VideoManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section("Video Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Tags (comma separated)", text: $tags)
                }
                
                Section {
                    Button("Upload Video") {
                        Task {
                            await videoManager.uploadVideo(
                                from: selectedItem!,
                                title: title,
                                description: description,
                                tags: tags.split(separator: ",").map(String.init)
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || selectedItem == nil)
                }
            }
            .navigationTitle("Upload Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
} 