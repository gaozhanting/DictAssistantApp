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

    @State var selectedRadio: String = "ellipsis"
    
    var body: some View {
        HStack(alignment: .top) {
            Button(action: {
                withAnimation {
                    toggleCropper()
                }
            }, label: {
                Image(systemName: "rectangle.dashed.badge.record")
                    .font(.system(size: 30, weight: .light))
                    .padding(.all, 7)
                    .contentShape(Rectangle())
                    .background(Color.primary.opacity(0.15))
                    .cornerRadius(10)
            })
            .buttonStyle(PlainButtonStyle())
//            .padding()
            .frame(maxHeight: .infinity)
            .border(Color.green)
            
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
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .padding(.horizontal, 27)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            playingImage
                .font(.system(size: 20, weight: .regular))
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    toggle()
                }
            
        }
//        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(Color.red)
        .edgesIgnoringSafeArea(.top)
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
        ).frame(width: 300, height: 50)
    }
}
            
