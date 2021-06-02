//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/2.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var modelData: ModelData
    @ObservedObject var statusData: StatusData
    @ObservedObject var textProcessConfig: TextProcessConfig
    let toggleCropper: () -> Void
    let toggle: () -> Void
    let deleteAllWordStaticstics: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            if statusData.isPlaying {
                WordsView(modelData: modelData)
                    .padding(.top, 10)
                    .border(Color.green)
            }
            
            ControlView(
                statusData: statusData,
                textProcessConfig: textProcessConfig,
                toggleCropper: toggleCropper,
                toggle: toggle,
                deleteAllWordStaticstics: deleteAllWordStaticstics
            )
            .frame(height: 35)
            .padding(.horizontal, 10)
            .padding(.vertical, 2)
            .border(Color.red)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var statusData = StatusData()
    static var textProcessConfig = TextProcessConfig()
    static let modelData = ModelData()

    static var previews: some View {
        ContentView(
            modelData: modelData,
            statusData: statusData,
            textProcessConfig: textProcessConfig,
            toggleCropper: doNothing,
            toggle: doNothing,
            deleteAllWordStaticstics: doNothing
        )
        .frame(width: 300, height: 600)
    }
}
