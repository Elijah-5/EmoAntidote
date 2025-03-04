//
//  ContentView.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/14.
//

import SwiftUI
import Foundation
import AVFoundation

struct ContentView: View {
    @State private var currentView: String = "Main"
    @State private var emotion: String = "Default"
    @State private var intensity: Double = 0.5

    var body: some View {
        VStack {
            switch currentView {
            case "Main":
                ModeSelectionView(currentView: $currentView)
            case "MusicEmotionSelection":
                EmotionSelectionView(mode: "Music", currentView: $currentView, selectedEmotion: $emotion, intensity: $intensity)
            case "MazeEmotionSelection":
                EmotionSelectionView(mode: "Maze", currentView: $currentView, selectedEmotion: $emotion, intensity: $intensity)
            case "MazeInstruction":
                MazeView(currentView: $currentView, selectedEmotion: $emotion, intensity: $intensity)
            default:
                ModeSelectionView(currentView: $currentView)
            }
        }
        .onAppear {
            configureAudioSession()
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try session.setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}


#Preview {
    ContentView()
}
