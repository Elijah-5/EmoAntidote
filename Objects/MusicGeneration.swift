//
//  MusicGeneration.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/22.
//
import AVFoundation
import Foundation

func generateMusicAttributes(emotion: String, intensity: Double) -> (String, String) {
    let descriptors: [String: [String]] = [
        "Happy": ["bright", "cheerful", "uplifting", "energetic"],
        "Sad": ["mellow", "deep", "somber", "melancholic"],
        "Angry": ["harsh", "fierce", "intense", "aggressive"],
        "Afraid": ["uneasy", "tense", "alarming", "terrifying"],
        "Nervous": ["hesitant", "jittery", "anxious", "panicked"]
    ]
    
    let genres: [String: [String]] = [
        "Happy": ["Pop", "Folk", "Funk", "Dance"],
        "Sad": ["Blues", "Jazz", "Acoustic", "Classical"],
        "Angry": ["Metal", "Hard Rock", "Industrial", "Punk"],
        "Afraid": ["Dark Ambient", "Horror Soundtrack", "Experimental"],
        "Nervous": ["Minimal Electronic", "Indie Rock", "Synthwave", "Psychedelic"]
    ]
    
    guard let descriptorList = descriptors[emotion],
          let genreList = genres[emotion] else {
        return ("neutral", "Unknown")
    }
    
    let noise = Double.random(in: -0.1...0.1)
    let adjustedIntensity = max(0.0, min(1.0, intensity + noise))
    let weightedIndex = Int(pow(adjustedIntensity, 2.0) * Double(descriptorList.count - 1))
    let descriptor = descriptorList[min(weightedIndex, descriptorList.count - 1)]
    let genre = genreList.randomElement() ?? "Unknown"
    
    return (descriptor, genre)
}


func playRandomTrack(for selectedEmotion: String, with audioPlayer: inout AVAudioPlayer?) {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    do {
        let files = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        let filteredTracks = files.filter { $0.lastPathComponent.hasPrefix(selectedEmotion) && $0.pathExtension == "mp3" }
        
        if let randomTrack = filteredTracks.randomElement() {
            audioPlayer?.pause()
            audioPlayer = try AVAudioPlayer(contentsOf: randomTrack)
            audioPlayer?.play()
            print("Now playing: \(randomTrack.lastPathComponent)")
        } else {
            print("No track found for emotion: \(selectedEmotion)")
        }
    } catch {
        print("Error retrieving tracks: \(error.localizedDescription)")
    }
}
