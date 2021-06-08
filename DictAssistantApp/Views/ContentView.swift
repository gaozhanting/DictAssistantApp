//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/2.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var statusData: StatusData
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if statusData.isPlaying {
                WordsView()
            }
            
            ControlView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.75))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.toggleCropper, {})
            .environmentObject(TextProcessConfig())
            .environmentObject(StatusData(isPlaying: true))
            .environmentObject(RecognizedText(
                texts: ["Tomorrow - A mystical land where 99% of all human productivity, motivation and achievement are stored"]
            ))
            .frame(width: 1000, height: 300)
    }
}
