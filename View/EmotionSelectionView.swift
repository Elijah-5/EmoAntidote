//
//  EmotionSelection.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/14.
//
import SwiftUI
import Foundation
import AVFoundation

var audioPlayer: AVAudioPlayer?

struct EmotionSelectionView: View {
	var mode: String
	
	@Binding var currentView: String
	@Binding var selectedEmotion: String
	@Binding var intensity: Double
	@State private var isLoading: Bool = false
	@State private var isPresented: Bool = false
	@State private var tracks: [String] = []
	//Muisc generation count down
	@State private var timeRemaining = 45
	@State private var timerEnded = false
	@StateObject private var musicLibraryManager = MusicLibraryManager()
	
	@State private var isPlayExisting = true
	
	//    @StateObject private var musicViewModel = MusicViewModel() // Initialize the view model
	
	let emotions = ["Happy", "Sad", "Angry", "Afraid", "Nervous"]
	
	var body: some View {
		ZStack{
			Color(switchColor(for: selectedEmotion))
				.ignoresSafeArea()
				.animation(.easeInOut(duration: 0.5), value: selectedEmotion)
			VStack{
				topBar
				VStack{
					Text("Choose \n Your \n Emotion.")
						.bold()
						.foregroundStyle(.white)
						.font(.largeTitle)
						.frame(width: 200, height: 180, alignment: .topLeading)
						.padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
					
					EmotionDisplayView
					
					Picker("Select Emotion", selection: $selectedEmotion) {
						ForEach(emotions, id: \.self) { emotion in
							Text(emotion)
						}
					}
					.pickerStyle(SegmentedPickerStyle())
					.frame(width: 330, height: 80)
					.padding(.init(top: 0, leading: 0, bottom: 20, trailing: 0))
					
					Slider(value: $intensity, in: 0...1, step: 0.05)
						.padding()
					
					ActionButton
					
					
					if mode == "Music" && isLoading {
						LoadingView
					}
				}
				.frame(width: 400, height: 700)
			}
		}.sheet(isPresented: $isPresented, content: {
			MusicLibraryView(currentView: $currentView, isPresented: $isPresented, musicLibraryManager: musicLibraryManager)
		})
	}
	
	// Loading view when generating
	var LoadingView: some View{
		HStack{
			ProgressView(timerEnded ? "In a second" : "Approximate time: \(timeRemaining) seconds")
				.progressViewStyle(CircularProgressViewStyle())
				.padding()
				.onAppear{
					startCountdown()
				}
		}
	}
	
	
	// Button for playing existing music while generating
	var ActionButton: some View{
		HStack{
			Button(action: {
				if !isLoading{
					if mode == "Music" {
						isLoading = true
						Task {
							if(isPlayExisting){
								playRandomTrack(for: selectedEmotion, with: &audioPlayer)
							}
							let (descriptor, genre) = generateMusicAttributes(emotion: selectedEmotion, intensity: intensity)
							await generateMusicTrack(descriptor: descriptor, genre: genre)
						}
					} else {
						currentView = "MazeInstruction"
					}
				}
			}, label: {
				ZStack{
					RoundedRectangle(cornerRadius: 30)
						.foregroundStyle(.white)
						.shadow(radius: 10)
					Text("Generate")
						.bold()
						.foregroundStyle(isLoading ? .gray: Color("DarkBlue"))
						.font(.system(size: 22))
				}.frame(width: 260, height: 65, alignment: .center)
			})
				.padding()
		}
		
	}
	
	// Top Bar Buttons
	var topBar: some View {
		HStack {
			if currentView == "MusicEmotionSelection" {
				Button(action: {
					currentView = "ModeSelection"
				}, label: {
					Image(systemName: "arrow.backward")
						.foregroundStyle(.white)
				}).frame(width: 120, height: 50, alignment: .topLeading)
				HStack{
					Toggle(isOn: $isPlayExisting, label: {
						Image(systemName: "archivebox.fill")
							.foregroundStyle(.white)
							.padding(.init(top: 0, leading: 100, bottom: 0, trailing: 0))
					})
				Button(action: {
					isPresented = true
				}, label: {
					Image(systemName: "music.note.list")
						.foregroundStyle(.white)
				})
				}
					.frame(width: 180, height: 50, alignment: .topLeading)
			} else {
				Button(action: {
					currentView = "ModeSelection"
				}, label: {
					Image(systemName: "arrow.backward")
						.foregroundStyle(.white)
				}).frame(width: 320, height: 50, alignment: .topLeading)
			}
		}
	}
	
	var EmotionDisplayView: some View {
		Text(switchEmoji(for: selectedEmotion))
			.font(.system(size: 60 + intensity * 60))
			.animation(.smooth(duration: 0.3), value: intensity)
			.frame(width: 150, height: 180, alignment: .center)
			.overlay(alignment: .center, content: {
				//top leading
				Text((intensity>0.55) ? switchSubEmoji(for: selectedEmotion, in: 0) : "")
					.font(.system(size: 24 + intensity * 50))
					.offset(CGSizeMake(-40 - intensity * 60, -35 - intensity * 60))
					.animation(.smooth(duration: 0.5), value: intensity)
				//bottom leading
				Text((intensity>0.55) ? switchSubEmoji(for: selectedEmotion, in: 1) : "")
					.font(.system(size: 15 + intensity * 30))
					.offset(CGSizeMake(-35 - intensity * 45, 40 + intensity * 60))
					.animation(.smooth(duration: 0.5), value: intensity)
				//top trailing
				Text((intensity>0.55) ? switchSubEmoji(for: selectedEmotion, in: 2) : "")
					.font(.system(size: 15 + intensity * 30))
					.offset(CGSizeMake(45 + intensity * 65, -35 - intensity * 45))
					.animation(.smooth(duration: 0.5), value: intensity)
				// bottom trailing
				Text((intensity>0.55) ? switchSubEmoji(for: selectedEmotion, in: 3) : "")
					.font(.system(size: 20 + intensity * 40))
					.offset(CGSizeMake(45 + intensity * 50, 45 + intensity * 50))
					.animation(.smooth(duration: 0.5), value: intensity)
			})
			.padding(.init(top: 0, leading: 0, bottom: 65, trailing: 0))
		
	}
	
	
	
	private func startCountdown() {
		timeRemaining = 45
		// Create a timer to update the timeRemaining every second
		Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
			if timeRemaining > 1 {
				timeRemaining -= 1
				if !isLoading{
					return
				}
			} else {
				timerEnded = true
				timer.invalidate() // Stop the timer once it reaches 1
			}
		}
	}
	
	
	func generateMusicTrack(descriptor: String, genre:String) async {
		let beatovenAPI = BeatovenAPI()
		let prompt_text = generateMusicPrompt(descriptor: descriptor, genre: genre)
		let trackMeta = TrackMeta(prompt: Prompt(text: prompt_text))
		
		do {
			// Step 1: Create the track
			let trackResponse = try await beatovenAPI.createTrack(requestData: trackMeta)
			guard let trackId = trackResponse.tracks.first else {
				print("No track ID found in response.")
				return
			}
			print("Created track with ID: \(trackId)")
			
			// Step 2: Compose the track
			let composeResponse = try await beatovenAPI.composeTrack(requestData: trackMeta, trackId: trackId)
			if composeResponse.task_id.isEmpty {
				print("No track ID found in response.")
				return
			}
			
			let taskId = composeResponse.task_id
			
			print("Started composition task with ID: \(taskId)")
			
			// Step 3: Monitor the composition status
			var trackStatus = try await beatovenAPI.getTrackStatus(taskId: taskId)
			
			while trackStatus.status == "composing" {
				print("Track is still being composed...")
				do {
					try await Task.sleep(nanoseconds: 10 * 1_000_000_000) // Sleep for 10 seconds
				} catch {
					print("An error occurred while sleeping: \(error)")
				}
				
				trackStatus = try await beatovenAPI.getTrackStatus(taskId: taskId)
			}
			
			if trackStatus.status == "failed" {
				print("Track composition failed.")
				return
			}
			
			print("Tracked status now: \(trackStatus.status)")
			
			//step 4: downloading from the url
			guard let trackUrl = trackStatus.meta.track_url else {
				print("Track URL is missing in the response.")
				return
			}
			
			print("Downloading track file from: \(trackUrl)")
			
			let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
			let trackName = generateTrackName(descriptor: descriptor, genre: genre)
			let filePath = documentsDirectory.appendingPathComponent("\(trackName)_track.mp3")
			//			tracks.append(trackName)
			musicLibraryManager.addTrack(named: trackName)
			// Adding a check right before the download starts
			if trackUrl.isEmpty {
				print("Error: Track URL is empty!")
				return
			}
			
			do {
				try await beatovenAPI.downloadTrackFile(from: trackUrl, to: filePath.path)
				print("Composed! You can find your track as 'composed_track.mp3'")
			} catch {
				print("Download failed with error: \(error)")
			}
			musicLibraryManager.playMusic(named: trackName)
			// Step 5: Play the downloaded music
			do {
				
				print("Playing the composed track...")
			} catch {
				print("Error playing audio: \(error)")
			}
			
			isLoading = false
		} catch {
			print("An error occurred: \(error)")
			isLoading = false
		}
	}
	
	
	
	func switchEmoji(for emotion: String) -> String {
		switch emotion {
		case "Happy":
			return "😄"
		case "Sad":
			return "😢"
		case "Angry":
			return "😡"
		case "Afraid":
			return "😱"
		case "Nervous":
			return "😰"
		default:
			return "🙂"
		}
	}
	func switchSubEmoji(for emotion: String, in index: Int) -> String {
		let emojis: [String: [String]] = [
			"Happy": ["😼", "☺️", "🥳", "😊"],
			"Sad": ["😢", "🥹", "☹️", "😣"],
			"Angry": ["😾", "💢", "😤", "😠"],
			"Afraid": ["🙀", "😨", "😧", "🫣"],
			"Nervous": ["😩", "😥", "😫", "😖"],
		]
		
		if let emotionEmojis = emojis[emotion] {
			//			return emotionEmojis.randomElement() ?? "🙂"
			return emotionEmojis[index]
		} else {
			return "🙂"
		}
	}
	
	
	func switchColor(for emotion: String) -> String {
		switch emotion {
		case "Happy":
			return "Yellow"
		case "Sad":
			return "Blue"
		case "Angry":
			return "Red"
		case "Afraid":
			return "Purple"
		case "Nervous":
			return "Orange"
		default:
			return "FlatBlue"
		}
	}
	
	func generateMusicPrompt(descriptor: String, genre: String) -> String {
		
		//		var intensityDescription: String
		let result = "a 30 second track of \(selectedEmotion) and \(descriptor) \(genre) music"
		return result
	}
	
	func generateTrackName(descriptor: String, genre: String) -> String {
		let randomNumber = Int.random(in: 0...999)
		let result = "\(selectedEmotion)_\(descriptor)_\(genre)_\(randomNumber)"
		return result
	}
}


struct MusicSelectionView_Previews: PreviewProvider {
	@State static private var currentView = "MusicEmotionSelection"  // Use `@State` on the parent struct level
	@State static private var selectedEmotion = "Default"
	@State static private var intensity = 0.5
	
	static var previews: some View {
		EmotionSelectionView(mode: "Music", currentView: $currentView, selectedEmotion: $selectedEmotion, intensity: $intensity)  // Pass the binding properly
	}
}
