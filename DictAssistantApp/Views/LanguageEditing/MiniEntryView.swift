//
//  MiniEntryView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/11.
//

import SwiftUI

func notifyPanel(panel: NSPanel, title: String, info: String) {
    panel.title = NSLocalizedString(info, comment: "")
    Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { timer in
        panel.title = NSLocalizedString(title, comment: "")
    }
}

struct MiniEntryView: View {
    @State var text: String = ""
    
    func upsert() {
        let wt = text.split(separator: Character(","), maxSplits: 1)
        upsertEntry(word: String(wt[0]), trans: String(wt[1]), didSucceed: {
            notifyPanel(panel: miniEntryPanel, title: "Mini Custom Entry Panel", info: "Succeed")
        }, nothingChanged: {
            notifyPanel(panel: miniEntryPanel, title: "Mini Custom Entry Panel", info: "Nothing Changed")
        })
    }
    
    var valid: Bool {
        !text.isEmpty && !text.isMultiline && text.split(separator: Character(","), maxSplits: 1).count == 2
    }
    
    var body: some View {
        HStack {
            TextField("Edit an entry", text: $text)
                .font(.headline)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: upsert) {
                Image(systemName: "plus")
            }
            .disabled(!valid)
            .keyboardShortcut(KeyEquivalent.return)
        }
        .padding()
        .frame(width: 450, height: 40)
    }
}

extension String {
    var isMultiline: Bool {
        self.contains { c in
            c.isNewline
        }
    }
}

struct EntryUpsertView_Previews: PreviewProvider {
    static var previews: some View {
        MiniEntryView()
    }
}
