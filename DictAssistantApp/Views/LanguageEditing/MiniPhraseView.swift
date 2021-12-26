//
//  MiniPhraseView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/11.
//

import SwiftUI

struct MiniPhraseView: View {
    @State var text: String = ""
    
    func add() {
        addPhrase(text, didSucceed: {
            notifyPanel(panel: miniPhrasePanel, title: "Mini Phrase Panel", info: "Succeed")
            
        }, nothingChanged: {
            notifyPanel(panel: miniPhrasePanel, title: "Mini Phrase Panel", info: "Nothing Changed")
        })
    }
    
    var valid: Bool {
        !text.isEmpty && !text.isMultiline && text.isPhrase
    }
    
    var body: some View {
        HStack {
            TextField("Edit a phrase", text: $text)
                .font(.headline)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: add) {
                Image(systemName: "plus")
            }
            .disabled(!valid)
            .keyboardShortcut(KeyEquivalent.return)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PhraseInsertView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPhraseView()
            .frame(width: 300, height: 42)
    }
}
