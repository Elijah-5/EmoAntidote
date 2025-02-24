//
//  GPTHistory.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/18.
//
import SwiftUI

class GPTHistory: ObservableObject {
    @Published var history: [String] = []
    
    func addResponse(_ response: String) {
        // Ensure this happens on the main thread
        DispatchQueue.main.async {
            self.history.append(response)
        }
    }
}

