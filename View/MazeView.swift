import SwiftUI

struct MazeView: View {
    @Binding var currentView: String
    @Binding var selectedEmotion: String
    @Binding var intensity: Double
    
    @State var displayedText: String = "In a second."
    @State var isBlock: Bool = false
    @State var isInitial: Bool = true
    @StateObject var gptHistory = GPTHistory()
    @State var isPresent = false
    @State var isFishTTS = true
    @State private var selectedVoice: Actor = .maleVoice1
    var fishTTS = FishTTS()
    var ttsManager = TTSManager()
    
    var openAI = OpenAIAPI(apiKey: "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")
    
    var body: some View {
        VStack {
            topBar
            VStack {
                Text(displayedText)
                    .bold()
                    .font(.largeTitle)
                    .frame(width: 300, height: 500, alignment: .leading)
                    .padding(.init(top: 100, leading: 0, bottom: 0, trailing: 20))
                    
                
                // Display the history of GPT responses
                //                ScrollView {
                //                    VStack(alignment: .leading) {
                //                        ForEach(gptHistory.history, id: \.self) { response in
                //                            Text(response)
                //                                .padding()
                //                                .border(Color.gray, width: 1)
                //                        }
                //                    }
                //                }
                //                .frame(height: 200)
                
                HStack {
                    if !isBlock {
                        HStack {
                            LeftRightButton(isLeft: true) {
                                keepGenerate(isLeft: true)
                            }
                            .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 100))
                            
                            LeftRightButton(isLeft: false) {
                                keepGenerate(isLeft: false)
                            }
                        }
                        .frame(width: 400, height: 200)
                        .padding(.init(top: 0, leading: 0, bottom: 100, trailing: 0))
                    } else {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 400, height: 200)
                            .padding(.init(top: 0, leading: 0, bottom: 100, trailing: 0))
                    }
                }
            }
            .frame(width: 300, height: 450)
            .padding(.init(top: 0, leading: 0, bottom: 100, trailing: 0))
        }
        .onAppear {
            if (isInitial) {
                initialInstruction()
                isInitial = false
            }
        }
        .sheet(isPresented: $isPresent, content: {
            HistoryView(isPresented: $isPresent, gptHistory: gptHistory)
        })
    }
    
    var topBar: some View{
        HStack{
            Button(action: {
                currentView = "ModeSelection"
            }, label: {
                Image(systemName: "arrow.backward")
                    .foregroundStyle(.black)
            }).frame(width: 50, height: 100, alignment: .topLeading)
                .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            HStack{
                Picker("Select Voice", selection: $selectedVoice) {
                                ForEach(Actor.allCases, id: \.self) { voice in
                                    Text(voice.rawValue)
                                }
                            }
                            .pickerStyle(WheelPickerStyle()) // Custom picker style\
                            .frame(width:200, height: 100)

                Image(systemName: "wand.and.stars")
                    .font(.title2)
                Toggle(isOn: $isFishTTS) {
                }
                Spacer()
                Button(action: {
                    isPresent = true
                }, label: {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.black)
                })
            }
            .frame(width: 300, height: 100, alignment: .topTrailing)
            .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    func initialInstruction() {
        if (!isBlock) {
            isBlock = true
            print("initialInstruction called")
            if let prompt = loadTextFromBundle(filename: "prompts") {
                openAI.generateText(prompt: "\(prompt)\n#Now the user's emotion is \(selectedEmotion) and the intensity is \(intensity) out of 1") { result in
                    switch result {
                    case .success(let generatedText):
                        let (concise, full) = separateResponse(response: generatedText)
                        
                        if let conciseText = concise {
                            displayedText = conciseText
                        }
                        
                        if let fullText = full {
                            print("Full version: \(fullText)")
                            gptHistory.addResponse(fullText) // Add response to history
                            if isFishTTS{
                                fishTTS.voiceActor = selectedVoice // Change voice actor if needed
                                fishTTS.ttsFishAudioTime(sentence: fullText)
                            }else{
                                ttsManager.speakText(fullText)
                            }
                        }
                        isBlock = false
                    case .failure(let error):
                        print("Error: \(error)")
                        isBlock = false
                    }
                }
            }
        }
    }
    
    func keepGenerate(isLeft: Bool) {
        if !isBlock{
            isBlock = true
            var pickedSide = "right"
            if isLeft {
                pickedSide = "left"
            }
            if let prompt = loadTextFromBundle(filename: "prompts_2") {
                openAI.generateText(prompt: "\(prompt). The previous instruction is '\(gptHistory)' Now, The user chose \(pickedSide) side, keep generate. The user's emotion is\(selectedEmotion) and the intensity is \(intensity) out of 1.") { result in
                    switch result {
                    case .success(let generatedText):
                        let (concise, full) = separateResponse(response: generatedText)
                        
                        if let conciseText = concise {
                            displayedText = conciseText
                            // Add response to history
                            //
                            
                        }
                        
                        if let fullText = full {
                            //                            print("Full version: \(fullText)")
                            gptHistory.addResponse(fullText)
                            if isFishTTS{
                                fishTTS.voiceActor = selectedVoice // Change voice actor if needed
                                fishTTS.ttsFishAudioTime(sentence: fullText)
                            }else{
                                ttsManager.speakText(fullText)
                            }
                        }
                        isBlock = false
                    case .failure(let error):
                        print("Error: \(error)")
                        isBlock = false
                    }
                }
            }
        }
    }
}

struct LeftRightButton: View {
    @State private var isPressed: Bool = false
    var isLeft: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Circle()
                .fill(.white)
                .frame(width: isPressed ? 120 : 100, height: isPressed ? 120 : 100)
                .shadow(radius: isPressed ? 12 : 10)
                .overlay(content: {
                    Text(isLeft ? "L" : "R")
                        .font(.system(size: isPressed ? 24 : 32))
                        .bold()
                        .foregroundStyle(.black)
                })
                .animation(.easeInOut(duration: 0.1), value: isPressed) // Smooth transition
        })
        .simultaneousGesture(
            DragGesture(minimumDistance: 0) // This will detect when press begins and ends
                .onChanged { _ in
                    withAnimation {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation {
                        isPressed = false
                    }
                }
        )
    }
}

func separateResponse(response: String) -> (concise: String?, full: String?) {
    // Regular expression to match the concise version within the square brackets
    let concisePattern = "\\[(.*?)\\]"
    
    var conciseText: String? = nil
    var fullText: String? = nil
    
    // Find concise version using regular expression
    if let conciseRange = response.range(of: concisePattern, options: .regularExpression) {
        conciseText = response[conciseRange].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
    }
    
    // The full version is the entire response, so just assign the full response
    fullText = response
    
    // Return both concise and full version as a tuple
    return (conciseText, fullText)
}


struct MazeView_Previews: PreviewProvider {
    @State static private var currentView = "MusicEmotionSelection"
    @State static private var selectedEmotion = "Default"
    @State static private var intensity = 0.5
    static var previews: some View {
        MazeView(currentView: $currentView, selectedEmotion: $selectedEmotion, intensity: $intensity, gptHistory: GPTHistory())
    }
}
