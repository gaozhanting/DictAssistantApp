//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import SwiftUI
import Vision

struct ControlView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var statusData: StatusData
    @EnvironmentObject var textProcessConfig: TextProcessConfig
    @Environment(\.toggleCropper) var toggleCropper
    @Environment(\.toggleContent) var toggleContent
    
    @State private var showingDeleteAlert = false
    
    var playingImage: Image {
        if statusData.isPlaying {
            return Image(systemName: "stop.fill")
        } else {
            return Image(systemName: "play.fill")
        }
    }
    
    var body: some View {
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
                Picker("DisplayMode", selection: $visualConfig.displayMode) {
                    Text("Landscape").tag(DisplayMode.landscape)
                    Text("Portrait").tag(DisplayMode.portrait)
                }
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .padding(.horizontal, 27)

            playingImage
                .padding(.horizontal)
                .onTapGesture {
                    toggleContent()
                }
        }
        .frame(maxWidth: 200, maxHeight: 45)
    }
    
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView()
            .frame(width: 300, height: 50)
            .environmentObject(StatusData(isPlaying: false))
            .environmentObject(TextProcessConfig())
            .environmentObject(VisualConfig(displayMode: .portrait, fontSizeOfLandscape: 20, fontSizeOfPortrait: 13))
            .environment(\.toggleCropper, {})
            .environment(\.toggleContent, {})

    }
}
