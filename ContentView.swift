//
//  ContentView.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/14.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var currentView: String = "Main"
    @State private var emotion: String = "Default"
    @State private var intensity: Double = 0.5
    var body: some View {
        VStack {
            switch currentView{
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
    }
}

#Preview {
    ContentView()
}
