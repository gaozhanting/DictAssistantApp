//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/2.
//

import SwiftUI
import DataBases
import Vision

struct ContentView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var statusData: StatusData
    @EnvironmentObject var recognizedText: RecognizedText

    @EnvironmentObject var textProcessConfig: TextProcessConfig
    @Environment(\.toggleCropper) var toggleCropper
    @Environment(\.toggleContent) var toggleContent
    
    var body: some View {
        switch visualConfig.displayMode {
        case .landscape:
            HStack(alignment: .center, spacing: 10) {
                if statusData.isPlaying {
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 10.0) {
                            ForEach(recognizedText.words, id: \.self) { word in
                                (Text(word).foregroundColor(.orange)
                                    + Text(translation(of: word)).foregroundColor(.white))
                                    .font(.system(size: 25))
                                    .onTapGesture {
                                        openDict(word)
                                    }
                                    .frame(maxWidth: 250)
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .frame(maxHeight: .infinity)
                    .border(Color.green)
                    .overlay(
                        Picker("DisplayMode:", selection: $visualConfig.displayMode) {
                            Text("Landscape").tag(DisplayMode.landscape)
                            Text("Portrait").tag(DisplayMode.portrait)
                        }
                        .frame(maxWidth: 200),
                        alignment: .bottomTrailing)
                }
                
                VStack(alignment: .center) {
                    Button(action: {
                        withAnimation {
                            toggleCropper()
                        }
                    }, label: {
                        Image(systemName: "rectangle.dashed.badge.record")
                            .contentShape(Rectangle())
                            .background(Color.primary.opacity(0.15))
                    })
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxHeight: .infinity)
                    
                    Menu("Options") {
                        Picker("TR Level", selection: $textProcessConfig.textRecognitionLevel) {
                            Text("Fast").tag(VNRequestTextRecognitionLevel.fast)
                            Text("Accurate").tag(VNRequestTextRecognitionLevel.accurate)
                        }
                        Picker("SC Intervel", selection: $textProcessConfig.screenCaptureTimeInterval) {
                            Text("5 seconds").tag(5.0)
                            Text("2 seconds").tag(2.0)
                            Text("1 second").tag(1.0)
                            Text("0.5 second").tag(0.5)
                            Text("0.3 second").tag(0.3)
                            Text("0.2 second").tag(0.2)
                            Text("0.1 second").tag(0.1)

                        }
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    .padding(.horizontal, 27)
                    .frame(maxHeight: .infinity)

                    playingImage
                        .padding(.horizontal)
                        .onTapGesture {
                            toggleContent()
                        }
                        .frame(maxHeight: .infinity)
                }
                .frame(width: 45)
                .border(Color.red)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.75))
        case .portrait:
            VStack() {
                if statusData.isPlaying {
                    List {
                        ForEach(recognizedText.words, id: \.self) { word in
                            (Text(word).foregroundColor(.orange)
                                + Text(translation(of: word)).foregroundColor(.white))
                                .font(.system(size: 15))
                                .onTapGesture {
                                    openDict(word)
                                }
                                .frame(maxHeight: 250)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(Color.green)
                    .overlay(
                        Picker("DisplayMode:", selection: $visualConfig.displayMode) {
                            Text("Landscape").tag(DisplayMode.landscape)
                            Text("Portrait").tag(DisplayMode.portrait)
                        }
                        .frame(maxWidth: 200),
                        alignment: .bottomTrailing)
                }
                
                HStack(alignment: .center) {
                    Button(action: {
                        withAnimation {
                            toggleCropper()
                        }
                    }, label: {
                        Image(systemName: "rectangle.dashed.badge.record")
                            .contentShape(Rectangle())
                            .background(Color.primary.opacity(0.15))
                    })
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxHeight: .infinity)
                    
                    Menu("Options") {
                        Picker("TR Level", selection: $textProcessConfig.textRecognitionLevel) {
                            Text("Fast").tag(VNRequestTextRecognitionLevel.fast)
                            Text("Accurate").tag(VNRequestTextRecognitionLevel.accurate)
                        }
                        Picker("SC Intervel", selection: $textProcessConfig.screenCaptureTimeInterval) {
                            Text("5 seconds").tag(5.0)
                            Text("2 seconds").tag(2.0)
                            Text("1 second").tag(1.0)
                            Text("0.5 second").tag(0.5)
                            Text("0.3 second").tag(0.3)
                            Text("0.2 second").tag(0.2)
                            Text("0.1 second").tag(0.1)

                        }
                    }
                    .menuStyle(BorderlessButtonMenuStyle())
                    .padding(.horizontal, 27)
                    .frame(maxHeight: .infinity)

                    playingImage
                        .padding(.horizontal)
                        .onTapGesture {
                            toggleContent()
                        }
                        .frame(maxHeight: .infinity)
                }
                .frame(height: 45)
                .border(Color.red)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.75))
        }
    }
    
    var playingImage: Image {
        if statusData.isPlaying {
            return Image(systemName: "stop.fill")
        } else {
            return Image(systemName: "play.fill")
        }
    }
    
    func translation(of word: String) -> String {
        if let tr = DictionaryServices.define(word) {
            return tr
        } else {
            return ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environment(\.toggleCropper, {})
                .environmentObject(TextProcessConfig())
                .environmentObject(VisualConfig(displayMode: .landscape))
                .environmentObject(StatusData(isPlaying: true))
                .environmentObject(RecognizedText(
                    texts: ["Tomorrow - A mystical land where 99% of all human productivity, motivation and achievement are stored"]
                ))
                .frame(width: 1000, height: 300)
            
            ContentView()
                .environment(\.toggleCropper, {})
                .environmentObject(TextProcessConfig())
                .environmentObject(VisualConfig(displayMode: .portrait))
                .environmentObject(StatusData(isPlaying: true))
                .environmentObject(RecognizedText(
                    texts: ["Tomorrow - A mystical land where 99% of all human productivity, motivation and achievement are stored"]
                ))
                .frame(width: 300, height: 1000)
        }
    }
}
