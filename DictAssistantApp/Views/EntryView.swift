//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import SwiftUI

struct EntryView: View {
    let toggle: () -> Void
    let exit: () -> Void
    let deleteAllWordStaticstics: () -> Void
    
    @ObservedObject var statusData: StatusData
    
    let showCropper: () -> Void
    let closeCropper: () -> Void

    @State private var showingDeleteAlert = false
    
    @State private var x: String = "0"
    @State private var y: String = "50"
    @State private var w: String = "700"
    @State private var d: String = "400"
    
    @State private var interval: String = "2"

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
                showCropper()
            }) {
                Text("show crop view")
            }
            
            Button(action: {
                closeCropper()
            }) {
                Text("close crop view")
            }

            Button(action: {
                toggle()
            }) {
                if statusData.isPlaying {
                    Text("Pause")
                } else {
                    Text("Start")
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
                exit()
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
//        PopoverView(start: emptyFunc,
//                    pause: emptyFunc)
//    }
//}
            
