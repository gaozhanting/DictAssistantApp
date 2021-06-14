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
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        VStack {
            ControlView()
                .frame(maxWidth: 220, alignment: .trailing)
                .opacity(visualConfig.miniMode ? 0 : 1)
            SimpleWordsView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .frame(width: 1000, height: 300)
                .environmentObject(TextProcessConfig(textRecognitionLevel: .fast, screenCaptureTimeInterval: 1.0))
                .environmentObject(VisualConfig(miniMode: false, displayMode: .landscape, fontSizeOfLandscape: 20, fontSizeOfPortrait: 13))
                .environmentObject(StatusData(isPlaying: true))
                .environmentObject(RecognizedText(
                    texts: ["Tomorrow - A mystical land where 99% of all human productivity, motivation and achievement are stored"]
                ))

            ContentView()
                .environment(\.toggleCropper, {})
                .environmentObject(TextProcessConfig(textRecognitionLevel: .fast, screenCaptureTimeInterval: 1.0))
                .environmentObject(VisualConfig(miniMode: false, displayMode: .portrait, fontSizeOfLandscape: 20, fontSizeOfPortrait: 13))
                .environmentObject(StatusData(isPlaying: true))
                .environmentObject(RecognizedText(
                    texts: ["Tomorrow - A mystical land where 99% of all human productivity, motivation and achievement are stored"]
                ))
                .frame(width: 300, height: 1000)
        }
    }
}
