//
//  EntryUpsertView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/11.
//

import SwiftUI

struct EntryUpsertView: View {
    @State private var text: String = ""
    
    func upsert() {
        let wt = text.split(separator: Character(","), maxSplits: 1)
        upsertEntry(word: String(wt[0]), trans: String(wt[1]), didSucceed: {
            entryUpsertPanel.title = "Succeed"
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { timer in
                entryUpsertPanel.title = "Entry Upsert"
            }
        }, nothingChanged: {
            entryUpsertPanel.title = "Nothing Changed"
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { timer in
                entryUpsertPanel.title = "Entry Upsert"
            }
        })
    }
    
    func valid() -> Bool {
        !text.isEmpty && !text.isMultiline && text.split(separator: Character(","), maxSplits: 1).count == 2
    }
    
    var body: some View {
        HStack {
            TextField("Upsert an entry", text: $text)
            
            Button(action: upsert) {
                Image(systemName: "rectangle.badge.plus")
            }
            .disabled(!valid())
            .keyboardShortcut(KeyEquivalent.return)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EntryUpsertView_Previews: PreviewProvider {
    static var previews: some View {
        EntryUpsertView()
    }
}
