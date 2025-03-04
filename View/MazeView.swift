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
    @State private var selectedVoice: Actor = .Voice1
    var fishTTS = FishTTS()
    var ttsManager = TTSManager()
    
    var openAI = OpenAIAPI(apiKey: "")
    
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
                audioPlayer?.pause()
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
//    func initialInstruction() {
//        if (!isBlock) {
//            isBlock = true
//            print("initialInstruction called")
//            if let prompt = loadTextFromBundle(filename: "prompts") {
//                openAI.generateText(prompt: "\(prompt)\n#Now the user's emotion is \(selectedEmotion) and the intensity is \(intensity) out of 1") { result in
//                    switch result {
//                    case .success(let generatedText):
//                        let (concise, full) = separateResponse(response: generatedText)
//                        
//                        if let conciseText = concise {
//                            displayedText = conciseText
//                        }
//                        
//                        if let fullText = full {
//                            print("Full version: \(fullText)")
//                            gptHistory.addResponse(concise: conciseText, full: fullText) // Add response to history
//                            if isFishTTS{
//                                fishTTS.voiceActor = selectedVoice // Change voice actor if needed
//                                fishTTS.ttsFishAudioTime(sentence: fullText)
//                            }else{
//                                ttsManager.speakText(fullText)
//                            }
//                        }
//                        isBlock = false
//                    case .failure(let error):
//                        print("Error: \(error)")
//                        isBlock = false
//                    }
//                }
//            }
//        }
//    }
    func initialInstruction() {
        guard !isBlock else { return }
        
        isBlock = true
        print("initialInstruction called")
        
        // Load prompt text safely
        guard let prompt = loadTextFromBundle(filename: "prompts") else {
            print("Error: Failed to load prompts")
            isBlock = false
            return
        }
        
        let fullPrompt = "\(prompt)\n#Now the user's emotion is \(selectedEmotion) and the intensity is \(intensity) out of 1"
        
        openAI.generateText(prompt: fullPrompt) { result in
            defer { isBlock = false } // Ensures isBlock resets no matter what
            
            switch result {
            case .success(let generatedText):
                var (concise, full) = separateResponse(response: generatedText) // Declare as var
                
                // Safely unwrap concise before modifying it
                if let conciseText = concise {
                    let updatedConcise = replaceSemicolonWithNewline(in: conciseText) // Replace ";" with newline
                    displayedText = updatedConcise // Update displayed text
                    concise = updatedConcise // Store back in concise
                }
                
                guard let fullText = full else {
                    print("Error: Full text is nil")
                    return
                }
                
                print("Full version: \(fullText)")
                gptHistory.addResponse(concise: concise, full: fullText) // Add response to history
                
                if isFishTTS {
                    fishTTS.voiceActor = selectedVoice // Change voice actor if needed
                    fishTTS.ttsFishAudioTime(sentence: fullText)
                } else {
                    ttsManager.speakText(fullText)
                }
                playRandomTrack(for: selectedEmotion, with: &audioPlayer, volume: 0.2)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }


    func keepGenerate(isLeft: Bool) {
        guard !isBlock else { return }
        
        isBlock = true
        let pickedSide = isLeft ? "left" : "right"

        // Load prompt text safely
        guard let prompt = loadTextFromBundle(filename: "prompts_2") else {
            print("Error: Failed to load prompts_2")
            isBlock = false
            return
        }
        
        let fullPrompt = """
        \(prompt). The previous instruction is '\(gptHistory.history.last?.full ?? "N/A")'.
        Now, the user chose the \(pickedSide) side, keep generating.
        The user's emotion is \(selectedEmotion) and the intensity is \(intensity) out of 1.
        """

        openAI.generateText(prompt: fullPrompt) { result in
            defer { isBlock = false } // Ensures isBlock resets

            switch result {
            case .success(let generatedText):
                var (concise, full) = separateResponse(response: generatedText) // Declare as var

                // Safely unwrap concise before modifying it
                if let conciseText = concise {
                    let updatedConcise = replaceSemicolonWithNewline(in: conciseText) // Replace ";" with newline
                    displayedText = updatedConcise // Update displayed text
                    concise = updatedConcise // Store back in concise
                }

                guard let fullText = full else {
                    print("Error: Full text is nil")
                    return
                }

                gptHistory.addResponse(concise: concise, full: fullText) // Add response to history
                
                if isFishTTS {
                    fishTTS.voiceActor = selectedVoice // Change voice actor if needed
                    fishTTS.ttsFishAudioTime(sentence: fullText)
                } else {
                    ttsManager.speakText(fullText)
                }
                
                playRandomTrack(for: selectedEmotion, with: &audioPlayer, volume: 0.2)
            case .failure(let error):
                print("Error: \(error)")
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

//func separateResponse(response: String) -> (concise: String?, full: String?) {
//    // Regular expression to match the concise version within the square brackets
//    let concisePattern = "\\[(.*?)\\]"
//    
//    var conciseText: String? = nil
//    var fullText: String? = nil
//    
//    // Find concise version using regular expression
//    if let conciseRange = response.range(of: concisePattern, options: .regularExpression) {
//        conciseText = response[conciseRange].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
//    }
//    
//    // The full version is the entire response, so just assign the full response
//    fullText = response
//    
//    // Return both concise and full version as a tuple
//    return (conciseText, fullText)
//}
func separateResponse(response: String) -> (concise: String?, full: String?) {
    // Regular expression to match the concise version within square brackets, allowing multiline content
    let concisePattern = "\\[(.*?)\\]"
    
    var conciseText: String? = nil
    var fullText: String = response
    
    // Find concise version using regular expression
    if let conciseRange = response.range(of: concisePattern, options: .regularExpression) {
        // Extract the content between the brackets
        conciseText = String(response[conciseRange])
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
        
        // Remove the concise part from the full text
        fullText.removeSubrange(conciseRange)
    }
    
    // Trim whitespace from the full text in case the concise part was at the beginning or end
    fullText = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Return concise and full text
    return (conciseText, fullText.isEmpty ? nil : fullText)
}




struct MazeView_Previews: PreviewProvider {
    @State static private var currentView = "MusicEmotionSelection"
    @State static private var selectedEmotion = "Default"
    @State static private var intensity = 0.5
    static var previews: some View {
        MazeView(currentView: $currentView, selectedEmotion: $selectedEmotion, intensity: $intensity, gptHistory: GPTHistory())
    }
}

func replaceSemicolonWithNewline(in text: String) -> String {
    return text.replacingOccurrences(of: ";", with: "\n")
}
