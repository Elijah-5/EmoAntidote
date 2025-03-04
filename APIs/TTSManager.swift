//
//  TTSManager.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/18.
//


import AVFoundation

import AVFoundation

//class TTSManager: NSObject {
//    private let speechSynthesizer = AVSpeechSynthesizer()
//
//    override init() {
//        super.init()
//        speechSynthesizer.delegate = self
//    }
//
//    // Method to start TTS
//    func speakText(_ text: String, voiceLanguage: String = "en-US", rate: Float = 0.5) {
//        let speechUtterance = AVSpeechUtterance(string: text)
//        speechUtterance.pitchMultiplier = 0.8
//        speechUtterance.postUtteranceDelay = 0.2
//        speechUtterance.voice = AVSpeechSynthesisVoice(language: voiceLanguage)
//        speechUtterance.rate = rate
//        speechSynthesizer.speak(speechUtterance)
//    }
//}
//
//// Conform to AVSpeechSynthesizerDelegate to handle speech completion and errors
//extension TTSManager: AVSpeechSynthesizerDelegate {
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        print("Speech finished: \(utterance.speechString)")
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didEncounterError error: Error) {
//        print("Error encountered during speech synthesis: \(error.localizedDescription)")
//    }
//}
//import AVFoundation
//
//class TTSManager: NSObject {
//    private let speechSynthesizer = AVSpeechSynthesizer()
//    private var completion: (() -> Void)? // Callback for speech completion
//
//    override init() {
//        super.init()
//        speechSynthesizer.delegate = self
//    }
//
//    // Method to start TTS
//    func speakText(_ text: String,
//                   voiceLanguage: String = "en-US",
//                   rate: Float = 0.5,
//                   pitch: Float = 1.0,
//                   completion: (() -> Void)? = nil) {
//        
//        self.completion = completion // Store completion callback
//
//        // Find the best available voice for the language
//        let voice = findBestVoice(for: voiceLanguage) ?? AVSpeechSynthesisVoice(language: voiceLanguage)
//
//        guard let selectedVoice = voice else {
//            print("Voice not available for language: \(voiceLanguage)")
//            return
//        }
//
//        let speechUtterance = AVSpeechUtterance(string: text)
//        speechUtterance.voice = selectedVoice
//        speechUtterance.rate = rate
//        speechUtterance.pitchMultiplier = pitch
//        speechUtterance.volume = 1.0
//        speechUtterance.postUtteranceDelay = 0.2
//
//        speechSynthesizer.speak(speechUtterance)
//    }
//
//    // Find the highest-quality voice available
//    private func findBestVoice(for language: String) -> AVSpeechSynthesisVoice? {
//        return AVSpeechSynthesisVoice.speechVoices()
//            .filter { $0.language == language }
//            .sorted { $0.quality.rawValue > $1.quality.rawValue } // Prioritize enhanced voices
//            .first
//    }
//
//    // Pause speech
//    func pauseSpeech() {
//        if speechSynthesizer.isSpeaking {
//            speechSynthesizer.pauseSpeaking(at: .word)
//        }
//    }
//
//    // Resume speech
//    func resumeSpeech() {
//        if speechSynthesizer.isPaused {
//            speechSynthesizer.continueSpeaking()
//        }
//    }
//
//    // Stop speech
//    func stopSpeech() {
//        if speechSynthesizer.isSpeaking {
//            speechSynthesizer.stopSpeaking(at: .immediate)
//        }
//    }
//
//    // Check if speaking
//    var isSpeaking: Bool {
//        return speechSynthesizer.isSpeaking
//    }
//}
//
//// Conform to AVSpeechSynthesizerDelegate to handle speech completion and errors
//extension TTSManager: AVSpeechSynthesizerDelegate {
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        print("Speech finished: \(utterance.speechString)")
//        completion?() // Call completion handler
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didEncounterError error: Error) {
//        print("Error encountered during speech synthesis: \(error.localizedDescription)")
//    }
//}


class TTSManager: NSObject {
    private let speechSynthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }

    // Method to start TTS
    func speakText(_ text: String, voiceLanguage: String = "en-US", rate: Float = 0.5, pitch: Float = 0.8) {
        // Ensure the voice exists
        guard let voice = AVSpeechSynthesisVoice(language: voiceLanguage) else {
            print("Voice not available for language: \(voiceLanguage)")
            return
        }

        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.pitchMultiplier = pitch
        speechUtterance.postUtteranceDelay = 0.2
        speechUtterance.voice = voice
        speechUtterance.rate = rate
        
        speechSynthesizer.speak(speechUtterance)
    }

    // Pause speech
    func pauseSpeech() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.pauseSpeaking(at: .immediate)
        }
    }

    // Stop speech
    func stopSpeech() {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    // Resume speech
    func resumeSpeech() {
        if !speechSynthesizer.isSpeaking {
            speechSynthesizer.continueSpeaking()
        }
    }
}

// Conform to AVSpeechSynthesizerDelegate to handle speech completion and errors
extension TTSManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Speech finished: \(utterance.speechString)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didEncounterError error: Error) {
        print("Error encountered during speech synthesis: \(error.localizedDescription)")
    }
}
