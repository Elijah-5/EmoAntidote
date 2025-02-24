//
//  ModeSelectionView.swift
//  EmoAntidote
//
//  Created by 林菁阳 on 2025/2/14.
//
//  Created by 林菁阳 on 2025/2/14.
//
import SwiftUI
import Foundation
import AVFoundation

struct ModeSelectionView: View {
    @Binding var currentView: String
    @State private var isPressed = false
    var body: some View {
        ZStack{
            Color("FlatBlue")
                .ignoresSafeArea()
            VStack{
                ModeLabelView(currentView: $currentView, labelTitle: "Music", labelImageName: "music.quarternote.3", toView: "MusicEmotionSelection")
                    .padding(.init(top: 0, leading: 0, bottom: 20, trailing: 0))
                ModeLabelView(currentView: $currentView, labelTitle: "Maze", labelImageName: "puzzlepiece.extension.fill", toView: "MazeEmotionSelection")
            }
        }
        
    }
    
}

struct ModeLabelView: View {
    @Binding var currentView: String
    @State private var isPressed = false
    var labelTitle: String
    var labelImageName: String
    var toView: String
    var body: some View {
            Button(action: {
                currentView = toView
            }, label: {
                RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                    .fill(.white)
                    .frame(width: isPressed ? 350: 330 , height: isPressed ? 267: 250, alignment:.center)
                    .shadow(radius: isPressed ? 12: 10)
                    .animation(.smooth(duration: 0.1), value: isPressed)
            })
            .overlay(content: {
                HStack{
                    Image(systemName: labelImageName)
                        .dynamicTypeSize(isPressed ? .xxxLarge : .large)
                        .foregroundStyle(.black)
                        .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 150))
                    Text(labelTitle)
                        .font(.system(size: isPressed ? 24: 32))
                        .bold()
                        .foregroundStyle(.black)
//                        .frame(width:130, height:140, alignment: .bottomTrailing)
                }.padding(.init(top: 180, leading: 0, bottom: 35, trailing: 0))
            })
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation{
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation{
                            isPressed = false
                        }
                    }
            )
    }
    
}
