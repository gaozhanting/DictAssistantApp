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
    @EnvironmentObject var statusData: StatusData
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if statusData.isPlaying {
                SimpleWordsView()
            }
            ControlView().frame(maxWidth: 220, alignment: .trailing)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .frame(width: 1000, height: 300)
                .environment(\.toggleCropper, {})
                .environmentObject(TextProcessConfig())
                .environmentObject(VisualConfig(displayMode: .landscape, fontSizeOfLandscape: 20, fontSizeOfPortrait: 13))
                .environmentObject(StatusData(isPlaying: true))
                .environmentObject(RecognizedText(
                    texts: ["Tomorrow - A mystical land where 99% of all human productivity, motivation and achievement are stored"]
                ))

            ContentView()
                .environment(\.toggleCropper, {})
                .environmentObject(TextProcessConfig())
                .environmentObject(VisualConfig(displayMode: .portrait, fontSizeOfLandscape: 20, fontSizeOfPortrait: 13))
                .environmentObject(StatusData(isPlaying: true))
                .environmentObject(RecognizedText(
                    texts: ["Tomorrow - A mystical land where 99% of all human productivity, motivation and achievement are stored"]
                ))
                .frame(width: 300, height: 1000)
        }
    }
}
