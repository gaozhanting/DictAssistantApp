//
//  MiniKnownView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/22.
//

import SwiftUI

struct MiniKnownView: View {
    @State var text: String = ""
    
    func remove() {
        removeKnown(text, didSucceed: {
            notifyPanel(panel: miniKnownPanel, title: "Mini Known Panel", info: "Succeed")
        }, nothingChanged: {
            notifyPanel(panel: miniKnownPanel, title: "Mini Known Panel", info: "Nothing Changed")
        })
    }
    
    func add() {
        addKnown(text, didSucceed: {
            notifyPanel(panel: miniKnownPanel, title: "Mini Known Panel", info: "Succeed")
        }, nothingChanged: {
            notifyPanel(panel: miniKnownPanel, title: "Mini Known Panel", info: "Nothing Changed")
        })
    }
    
    var valid: Bool {
        !text.isEmpty && !text.isMultiline
    }
    
    var body: some View {
        HStack {
            TextField("Edit a word", text: $text)
                .font(.headline)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: remove) {
                Image(systemName: "minus")
            }
            .disabled(!valid)
            
            Button(action: add) {
                Image(systemName: "plus")
            }
            .disabled(!valid)
        }
        .padding()
        .frame(width: 300, height: 40)
    }
}

struct MiniKnownView_Previews: PreviewProvider {
    static var previews: some View {
        MiniKnownView()
    }
}
