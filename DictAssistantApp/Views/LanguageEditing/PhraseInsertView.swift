//
//  PhraseInsertView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/11.
//

import SwiftUI

struct PhraseInsertView: View {
    @State private var text: String = ""
    
    func add() {
        addPhrase(text, didSucceed: {
            phraseInsertPanel.title = "Succeed"
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { timer in
                phraseInsertPanel.title = "Phrase Insert"
            }
        }, nothingChanged: {
            phraseInsertPanel.title = "Nothing Changed"
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { timer in
                phraseInsertPanel.title = "Phrase Insert"
            }
        })
    }
    
    func valid() -> Bool {
        !text.isEmpty && !text.isMultiline && text.isPhrase
    }
    
    var body: some View {
        HStack {
            TextField("Insert a phrase", text: $text)
            
            Button(action: add) {
                Image(systemName: "rectangle.badge.plus")
            }
            .disabled(!valid())
            .keyboardShortcut(KeyEquivalent.return)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PhraseInsertView_Previews: PreviewProvider {
    static var previews: some View {
        PhraseInsertView()
    }
}
