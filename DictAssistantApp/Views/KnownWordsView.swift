//
//  KnownWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/24.
//

import SwiftUI

struct KnownWordsView: View {
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordStats.word, ascending: true)
        ]
    ) var knownWords: FetchedResults<WordStats>
    
    var body: some View {
        List {
            Section(header: Text("Count: \(knownWords.count)")) {
                ForEach(knownWords, id: \.self) { word in
                    Text(word.word!)
                        .onTapGesture {
                            openDict(word.word!)
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
