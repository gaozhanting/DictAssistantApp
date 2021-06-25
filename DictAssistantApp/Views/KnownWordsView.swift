//
//  KnownWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/24.
//

import SwiftUI

struct KnownWordsView: View {
    @Environment(\.removeFromKnownWords) var removeFromKnownWords

    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordStats.word, ascending: true)
        ]
    ) var knownWords: FetchedResults<WordStats>
    
    var body: some View {
        List {
            Section(header: Text("Count: \(knownWords.count)")) {
                ForEach(knownWords, id: \.self) { element in
                    if let word = element.word {
                        Text(word)
                            .onTapGesture {
                                openDict(word)
                            }
                            .contextMenu {
                                Button("Remove from Known", action: { removeFromKnownWords(word) })
                            }
                    }
                }
            }
        }
    }
}

func openDict(_ word: String) {
    let task = Process()
    task.launchPath = "/usr/bin/open"
    var arguments = [String]();
    arguments.append("dict://\(word)")
    task.arguments = arguments
    task.launch()
}

struct KnownWordsView_Previews: PreviewProvider {
    static var previews: some View {
        KnownWordsView()
    }
}
