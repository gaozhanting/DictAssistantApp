//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import SwiftUI

struct ContentView: View {
    @State private var x: String = "100"
    @State private var y: String = "100"
    @State private var w: String = "500"
    @State private var d: String = "300"
    
    @State private var interval: String = "4"

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
            }) {
                if !isPlaying {
                    Text("Start")
                } else {
                    Text("Stop")
                }
            }
            
            Button(action: {
//                exit(0)
                NSApplication.shared.terminate(self)
            }) {
                Text("Exit")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
