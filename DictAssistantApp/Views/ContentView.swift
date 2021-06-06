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
        HStack {
            if statusData.isPlaying {
                WordsView()
                    .frame(maxHeight: .infinity)
                    .padding(.leading, 10)
                    .border(Color.green)
            }
            
            ControlView()
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
        ContentView()
            .frame(width: 300, height: 600)
            .environment(\.toggleCropper, {})
            .environmentObject(TextProcessConfig())
            .environmentObject(StatusData())
            .environmentObject(ModelData())
    }
}
