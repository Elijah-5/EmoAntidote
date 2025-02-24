//
//  FishTTS.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/18.
//

import Foundation
import AVFoundation

enum Actor: String, CaseIterable {
    case maleVoice1 = "Male Voice 1"
    case maleVoice2 = "Male Voice 2"
    case maleVoice3 = "Male Voice 3"
    case maleVoice4 = "Male Voice 4"
    case femaleVoice1 = "Female Voice 1"
    case femaleVoice2 = "Female Voice 2"
    case femaleVoice3 = "Female Voice 3"
    
    var referenceId: String {
        switch self {
        case .maleVoice1:
            return "ef9c79b62ef34530bf452c0e50e3c260"
        case .maleVoice2:
            return "e80ea225770f42f79d50aa98be3cedfc"
        case .maleVoice3:
            return "e4642e5edccd4d9ab61a69e82d4f8a14"
        case .maleVoice4:
            return "59cb5986671546eaa6ca8ae6f29f6d22"
        case .femaleVoice1:
            return "56431e329b21489c9f9f7ab9c77312d4"
        case .femaleVoice2:
            return "3ae4f876c3fb4f709737d117a68f388e"
        case .femaleVoice3:
            return "1a11a76a04b3459d9741feb4cf29b1dd"
            
        }
    }
}
class FishTTS {
    // API Configuration
    private let apiToken = "Your API token"
    private let apiUrl = "https://api.fish.audio/v1/tts"
    
    // Audio Configuration
    private var speakerName = "default_speaker"
    private var chunkLength = 200
    private var normalize = true
    private var format = "mp3"
    private var mp3Bitrate = 128
    private var latency = "normal"
    
    private var referenceIdInput = "DynamicReferenceID"  // To be set per voice actor
    
    // AVAudioPlayer for audio playback
    private var audioPlayer: AVAudioPlayer?
    
    // Voice actor options
    
    var voiceActor: Actor = .maleVoice1 {
        didSet {
            referenceIdInput = voiceActor.referenceId
        }
    }
    
    // Request TTS with Timing Logic
    func ttsFishAudioTime(sentence: String) {
        print("Sending TTS request for: \(sentence)")
        // Create the request payload
        let payload = TTSRequest(text: sentence,
                                 referenceId: referenceIdInput,
                                 chunkLength: chunkLength,
                                 normalize: normalize,
                                 format: format,
                                 mp3Bitrate: mp3Bitrate,
                                 opusBitrate: -1000, // Not used for MP3
                                 latency: latency)
        
        // Convert the payload to JSON
        guard let requestData = try? JSONEncoder().encode(payload) else {
            print("Error encoding request data.")
            return
        }
        
        // Send the request to the API
        sendRequestToFishAudio(requestData)
    }
    
    // Send the TTS request
    private func sendRequestToFishAudio(_ requestData: Data) {
        guard let url = URL(string: apiUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData

        // Send the HTTP request
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("TTS API Error: \(error.localizedDescription)")
                return
            }

            if let data = data {
                print("Received response data from Fish Audio API")
                if let strongSelf = self {
                    print("Strong self is available, calling handleAudioResponse...")
                    strongSelf.handleAudioResponse(data: data)
                } else {
                    print("Self is nil, cannot call handleAudioResponse")
                }
            }
        }
//        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
//            guard let strongSelf = self else {
//                print("Self is nil before closure executes.")
//                return
//            }
//            
//            if let error = error {
//                print("TTS API Error: \(error.localizedDescription)")
//                return
//            }
//
//            if let data = data {
//                print("Received response data from Fish Audio API")
//                strongSelf.handleAudioResponse(data: data)
//            }
//        }


        task.resume()
    }



    
    private func handleAudioResponse(data: Data) {
        print("Received audio data, size: \(data.count) bytes")  // This confirms we have audio data
        
        do {
            self.audioPlayer = try AVAudioPlayer(data: data)
            self.audioPlayer?.prepareToPlay()  // Prepare the player in advance
            self.audioPlayer?.play()  // Play the audio
            print("Audio playback started.")
        } catch {
            print("Error playing audio: \(error.localizedDescription)")  // Debugging line
        }
    }

    // Class to represent the TTS Request Payload
    struct TTSRequest: Codable {
        var text: String
        var referenceId: String
        var chunkLength: Int
        var normalize: Bool
        var format: String
        var mp3Bitrate: Int
        var opusBitrate: Int
        var latency: String
    }
}
