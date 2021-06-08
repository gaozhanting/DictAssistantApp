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
    
    var body: some View {
        switch visualConfig.displayMode {
        case .landscape:
            ZStack(alignment: .bottomTrailing) {
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.75))
                }
                
                ControlView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            
        case .portrait:
            ZStack(alignment: .bottomTrailing) {
                if statusData.isPlaying {
                    ScrollView(.vertical) {
                        VStack(alignment: .leading) {
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.75))
                }
                
                ControlView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

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
                .environmentObject(VisualConfig(displayMode: .portrait)) // cann't preview two different displayMode?
                .environmentObject(StatusData(isPlaying: true))
                .environmentObject(RecognizedText(
                    texts: ["Tomorrow - A mystical land where 99% of all human productivity, motivation and achievement are stored"]
                ))
                .frame(width: 300, height: 1000)
        }
    }
}
