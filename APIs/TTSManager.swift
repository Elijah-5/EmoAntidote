//
//  TTSManager.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/18.
//


import AVFoundation

import AVFoundation

class TTSManager: NSObject {
    private let speechSynthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }

    // Method to start TTS
    func speakText(_ text: String, voiceLanguage: String = "en-US", rate: Float = 0.1) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: voiceLanguage)
        speechUtterance.rate = rate
        speechSynthesizer.speak(speechUtterance)
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

