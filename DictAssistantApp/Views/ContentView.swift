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

    @State var showHistoryDrawer: Bool = false

    var body: some View {
        VStack {
//            ControlView(showHistoryDrawer: $showHistoryDrawer)
//                .frame(maxWidth: 220, alignment: .trailing)
//                .opacity(visualConfig.miniMode ? 0 : 1)
//
//            if showHistoryDrawer {
//                HistoryWordsView()
//            } else if statusData.isPlaying {
                WordsView()
//            } else {
//                Spacer()
//            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ContentView()
//                .frame(width: 1000, height: 300)
//                .environmentObject(TextProcessConfig(textRecognitionLevel: .fast))
//                .environmentObject(
//                    VisualConfig(
//                        miniMode: false,
//                        displayMode: .landscape,
//                        fontSizeOfLandscape: 20,
//                        fontSizeOfPortrait: 13,
//                        colorOfLandscape: .orange,
//                        colorOfPortrait: .green,
//                        fontName: NSFont.systemFont(ofSize: 0.0).fontName))
//                .environmentObject(StatusData(isPlayingInner: false, sideEffectCode: {}))
//                .environmentObject(RecognizedText(
//                    texts: ["Tomorrow - A mystical land where 99% of all human productivity, motivation and achievement are stored"]
//                ))
//
//            ContentView()
//                .environment(\.toggleCropper, {})
//                .environmentObject(TextProcessConfig(textRecognitionLevel: .fast))
//                .environmentObject(
//                    VisualConfig(
//                        miniMode: false,
//                        displayMode: .landscape,
//                        fontSizeOfLandscape: 20,
//                        fontSizeOfPortrait: 13,
//                        colorOfLandscape: .orange,
//                        colorOfPortrait: .green,
//                        fontName: NSFont.systemFont(ofSize: 0.0).fontName))
//                .environmentObject(StatusData(isPlayingInner: false, sideEffectCode: {}))
//                .environmentObject(RecognizedText(
//                    texts: ["Tomorrow - A mystical land where 99% of all human productivity, motivation and achievement are stored"]
//                ))
//                .frame(width: 300, height: 600)
//        }
//    }
//}
