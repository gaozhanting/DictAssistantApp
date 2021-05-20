//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import SwiftUI

struct PopoverView: View {
    let showWordsView: () -> Void
    let closeWordsView: () -> Void
    let startScreenCapture: () -> Void
    let stopScreenCapture: () -> Void
    let deleteAllWordStaticstics: () -> Void
    
    @State private var showingDeleteAlert = false
    
    @State private var x: String = "0"
    @State private var y: String = "50"
    @State private var w: String = "700"
    @State private var d: String = "400"
    
    @State private var interval: String = "2"

    @State private var isPlaying: Bool = false
    
    var body: some View {
        List {
            HStack {
                Text("x:")
                TextField("x", text: $x)
            }
            HStack {
                Text("y:")
                TextField("y", text: $y)
            }
            HStack {
                Text("w:")
                TextField("w", text: $w)
            }
            HStack {
                Text("d:")
                TextField("d", text: $d)
            }
            
            HStack {
                Text("interval (seconds):")
                TextField("interval", text: $interval)
            }

            Button(action: {
                isPlaying = !isPlaying
                if !isPlaying {
                    closeWordsView()
                    stopScreenCapture()
                } else {
                    showWordsView()
                    startScreenCapture()
                }
            }) {
                if !isPlaying {
                    Text("Start")
                } else {
                    Text("Stop")
                }
            }
            
            Button("DeleteAllWordStaticstics") {
                showingDeleteAlert = true
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Are you sure you want to delete all word statics information, and reset it to empty?"),
                    message: Text("Word statics information is stored and accumulated automatically whenever you use the app."),
                    primaryButton: .destructive(Text("delete"), action: deleteAllWordStaticstics),
                    secondaryButton: .cancel())
            }
            
            Button(action: {
                NSApplication.shared.terminate(self)
            }) {
                Text("Exit")
            }
        }
    }
}

func emptyFunc() -> Void {
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        PopoverView(showWordsView: emptyFunc,
//                    closeWordsView: emptyFunc,
//                    startScreenCapture: emptyFunc,
//                    stopScreenCapture: emptyFunc)
//    }
//}
            
