//
//  MusicGallery.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/17.
//
import SwiftUI

//struct HistoryView: View {
//    
//    @Binding var isPresented: Bool
//    @StateObject var gptHistory: GPTHistory
//    
//    var body: some View {
//               VStack {
//                   Text("Emotion Journey")
//                       .font(.title)
//                       .bold()
//                       .padding(.bottom, 10)
//                   
//                   List(gptHistory.history, id: \.self) { response in
//                       Text(response)
//                           .padding()
//                   }
//                   .frame(maxWidth: .infinity, maxHeight: .infinity)
//               }
//               .padding()
//    }
//    
//    var backButton: some View {
//        Button(action: {
//            isPresented = false
//        }) {
//            Image(systemName: "arrow.left")
//                .foregroundColor(.blue)
//        }
//    }
//}

struct HistoryView: View {
    @Binding var isPresented: Bool
    @StateObject var gptHistory: GPTHistory
    @State private var expandedIndex: Int? = nil // Track which item is expanded

    var body: some View {
        VStack {
            Text("Emotion Journey")
                .font(.title)
                .bold()
                .padding(.bottom, 10)

            List(gptHistory.history.indices, id: \.self) { index in
                let response = gptHistory.history[index]

                VStack(alignment: .leading) {
                    Text(response.concise ?? "No Summary")
                        .font(.headline)
                        .padding(.bottom, expandedIndex == index ? 5 : 0)
                        .onTapGesture {
                            withAnimation {
                                expandedIndex = (expandedIndex == index) ? nil : index
                            }
                        }

                    if expandedIndex == index {
                        Text(response.full)
                            .font(.body)
                            .transition(.opacity)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .navigationBarItems(leading: backButton)
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

