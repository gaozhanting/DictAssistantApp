//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/2.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var statusData: StatusData
    let toggleCropper: () -> Void
    let toggle: () -> Void
    let deleteAllWordStaticstics: () -> Void
    
    var body: some View {
        HStack {
            if statusData.isPlaying {
                WordsView()
                    .frame(maxHeight: .infinity)
                    .padding(.leading, 10)
                    .border(Color.green)
            }
            
            ControlView(
                toggleCropper: toggleCropper,
                toggle: toggle,
                deleteAllWordStaticstics: deleteAllWordStaticstics
            )
            .frame(width: 45)
            .frame(maxHeight: .infinity)
            .border(Color.red)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.75))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            toggleCropper: {},
            toggle: {},
            deleteAllWordStaticstics: {}
        )
        .frame(width: 300, height: 600)
        .environmentObject(TextProcessConfig())
        .environmentObject(StatusData())
        .environmentObject(ModelData())
    }
}
