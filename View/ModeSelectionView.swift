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
                Image("AppIcon-inverse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Spacer()
            }.frame(maxWidth: .infinity, alignment: .top)
            VStack{
                ModeLabelView(currentView: $currentView, labelTitle: "Music", labelDescription: "emotion-based music generation", labelImageName: "music.quarternote.3", toView: "MusicEmotionSelection")
                    .padding(.init(top: 0, leading: 0, bottom: 20, trailing: 0))
                ModeLabelView(currentView: $currentView, labelTitle: "Maze", labelDescription: "adaptive perception training", labelImageName: "puzzlepiece.extension.fill", toView: "MazeEmotionSelection")
            }
        }
        
    }
    
}

struct ModeLabelView: View {
    @Binding var currentView: String
    @State private var isPressed = false
    var labelTitle: String
    var labelDescription: String = ""
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
                        .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 80))
                    VStack{
                        Text(labelTitle)
                            .font(.system(size: isPressed ? 28: 36))
                            .bold()
                            .foregroundStyle(.black)
                        Divider()
                            //.padding(.init(top: 0, leading: 0, bottom: 15, trailing: 0))
                        Text(labelDescription)
                            .font(.system(size: isPressed ? 12 : 16))
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 150, height: 220, alignment: .trailing)
                    .padding(.init(top: 50, leading: 0, bottom: 0, trailing: 0))
                }.padding(.init(top: 80, leading: 0, bottom: 35, trailing: 0))
                    .frame(width: 280, height: 250)
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
