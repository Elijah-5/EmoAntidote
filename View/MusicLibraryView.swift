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
    @State private var showDeleteConfirmation = false
    @State private var trackToDelete: String? = nil

        var body: some View {
            NavigationView {
                List(musicLibraryManager.musicTracks, id: \.self) { track in
                    HStack {
                        Text(track)
                            .onTapGesture {
                                musicLibraryManager.playMusic(named: track)
                            }
                            .contextMenu {
                                Button(action: {
                                    trackToDelete = track
                                    showDeleteConfirmation = true
                                }) {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }

                        Spacer()
                        
                        // Trash button to delete track
                        Button(action: {
                            trackToDelete = track
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                .navigationTitle("My EmoTracks")
                .navigationBarItems(leading: backButton)
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Confirm Deletion"),
                        message: Text("Are you sure you want to delete this track?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let track = trackToDelete {
                                musicLibraryManager.deleteTrack(named: track)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
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
