//
//  MusicGallery.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/17.
//
import SwiftUI

struct HistoryView: View {
    
    @Binding var isPresented: Bool
    @StateObject var gptHistory: GPTHistory
    
    var body: some View {
               VStack {
                   Text("Meditation Journey")
                       .font(.title)
                       .bold()
                       .padding(.bottom, 10)
                   
                   List(gptHistory.history, id: \.self) { response in
                       Text(response)
                           .padding()
                   }
                   .frame(maxWidth: .infinity, maxHeight: .infinity)
               }
               .padding()
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
