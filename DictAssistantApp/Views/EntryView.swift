//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import SwiftUI
import Vision

struct EntryView: View {
    let toggle: () -> Void
    let deleteAllWordStaticstics: () -> Void
    
    @ObservedObject var statusData: StatusData
    
    let toggleCropper: () -> Void

    @State private var showingDeleteAlert = false
    
    @State private var x: String = "0"
    @State private var y: String = "50"
    @State private var w: String = "700"
    @State private var d: String = "400"
    
    @State private var interval: String = "2"
    
    @ObservedObject var textProcessConfig: TextProcessConfig

    var playingImage: Image {
        if statusData.isPlaying {
            return Image(systemName: "stop.fill")
        } else {
            return Image(systemName: "play.fill")
        }
    }

    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Menu("Options") {
                    Picker("TR Level", selection: $textProcessConfig.textRecognitionLevel) {
                        Text("Fast").tag(VNRequestTextRecognitionLevel.fast)
                        Text("Accurate").tag(VNRequestTextRecognitionLevel.accurate)
                    }
                    Picker("SC Intervel", selection: $textProcessConfig.screenCaptureTimeInterval) {
                        Text("1 second").tag(1.0)
                        Text("0.5 second").tag(0.5)
                        Text("0.3 second").tag(0.3)
                    }
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Image(systemName: "rectangle.dashed.badge.record")
                    .font(.system(size: 20, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        toggleCropper()
                    }

                playingImage
                    .font(.system(size: 20, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        toggle()
                    }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.top)
        }
    }
    
}

func doNothing() -> Void {
    
}

struct EntryView_Previews: PreviewProvider {
    static var textProcessConfig = TextProcessConfig()

    static var previews: some View {
        EntryView(
            toggle: doNothing,
            deleteAllWordStaticstics: doNothing,
            statusData: StatusData(),
            toggleCropper: doNothing,
            textProcessConfig: textProcessConfig
        ).frame(width: 300, height: 30)
    }
}
            
