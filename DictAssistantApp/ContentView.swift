//
//  ContentView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        List {
            
            Button(action: {
                print("Start/Pause")
            }) {
                Text("Start/Pause")
            }
            
            Button(action: {
                print("Exit")
                exit(0)
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
