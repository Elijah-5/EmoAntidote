//
//  MusicGallery.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/17.
//
import SwiftUI

struct MusicLibraryView: View {
    @Binding var currentView: String
    @Binding var isPresented: Bool
    @ObservedObject var musicLibraryManager: MusicLibraryManager
    
    var body: some View {
        NavigationView {
            List(musicLibraryManager.musicTracks, id: \.self) { track in
                HStack {
                    Text(track)
                        .onTapGesture {
                            musicLibraryManager.playMusic(named: track)
                        }
                    Spacer()
                    Button(action: {
                        musicLibraryManager.deleteTrack(named: track)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("My EmoTracks")
            .navigationBarItems(leading: backButton)
        }
        .onAppear {
            musicLibraryManager.loadTracks() // Load tracks when the view appears
        }
    }
    
    var backButton: some View {
        Button(action: {
            isPresented = false
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.blue)
        }
    }
}
