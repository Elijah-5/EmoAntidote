//
//  MusicLibraryObject.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/17.
//

import Foundation
import AVFoundation

class MusicLibraryManager: ObservableObject {
    @Published var musicTracks: [String] = []
    @Published var player: AVPlayer?

    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    init() {
        loadTracks() // Initialize by loading tracks
    }
    
    // Load tracks from the Documents directory
    func loadTracks() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            musicTracks = fileURLs
                .filter { $0.pathExtension == "txt" }
                .map { $0.lastPathComponent.replacingOccurrences(of: ".txt", with: "") }
        } catch {
            print("Error loading tracks: \(error)")
        }
    }

    // Play music
    func playMusic(named trackName: String) {
        // Pause any currently playing audio
        player?.pause()
        player?.seek(to: .zero)
        
        let filePath = documentsDirectory.appendingPathComponent("\(trackName)_track.mp3")
        let playerItem = AVPlayerItem(url: filePath)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
    }

    // Add a new track
    func addTrack(named track: String) {
        let trackURL = documentsDirectory.appendingPathComponent("\(track).txt")
        
        do {
            try track.write(to: trackURL, atomically: true, encoding: .utf8)
            loadTracks()
        } catch {
            print("Error adding track: \(error)")
        }
    }

    // Delete a track
    func deleteTrack(named track: String) {
        let trackURL = documentsDirectory.appendingPathComponent("\(track).txt")
        let trackFile = documentsDirectory.appendingPathComponent("\(track)_track.mp3")
        do {
            try FileManager.default.removeItem(at: trackURL)
            try FileManager.default.removeItem(at: trackFile)
            loadTracks()
        } catch {
            print("Error deleting track: \(error)")
        }
    }
}
