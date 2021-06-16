//
//  HistoryWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/16.
//

import SwiftUI

struct HistoryWordsView: View {
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordStats.presentCount, ascending: true)
        ],
        predicate: NSPredicate(format: "presentCount < \(familiarThreshold)")
    ) var unFamiliarWordStatss: FetchedResults<WordStats>
    
    var xUnFamiliarWordStatss: [WordStats] {
        if !searchedWord.isEmpty {
            return unFamiliarWordStatss.filter { wordStats in
                wordStats.word == searchedWord
            }
        }
        return unFamiliarWordStatss.filter { wordStats in
            wordStats.presentCount >= low
        }
    }
    
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordStats.presentCount, ascending: true)
        ],
        predicate: NSPredicate(format: "presentCount >= \(familiarThreshold)")
    ) var familiarWordStatss: FetchedResults<WordStats>
    
    var xFamiliarWordStatss: [WordStats] {
        if !searchedWord.isEmpty {
            return familiarWordStatss.filter { wordStats in
                wordStats.word == searchedWord
            }
        }
        return familiarWordStatss.filter { wordStats in
            wordStats.presentCount >= low
        }
    }

    @State var low: Int = 1
    let step = 1
    let range = 1...(5*familiarThreshold)
    
    @State private var eSearchedWord: String = ""
    @State private var isEditing = false
    @State private var searchedWord: String = ""
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                Section(
                    header:
                        VStack(alignment: .leading) {
                            Text("All Words Count: \(unFamiliarWordStatss.count + familiarWordStatss.count)")
                            
                            HStack {
                                Text("Filter:")
                                Spacer()
                                Stepper(value: $low,
                                        in: range,
                                        step: step) {
                                    Text("\(low)")
                                }
                            }
                            
                            HStack {
                                Text("Search: ")

                                TextField(
                                    "",
                                    text: $eSearchedWord
                                ) { isEditing in
                                    self.isEditing = isEditing
                                } onCommit: {
                                    searchedWord = eSearchedWord
                                }
                            }
                        }
                ) {}
                
                Section(header: Text("UnFamiliar Words Count: \(xUnFamiliarWordStatss.count)")) {
                    ForEach(xUnFamiliarWordStatss, id: \.self) { wordStats in
                        Text("\(wordStats.word!): \(wordStats.presentCount)")
                            .foregroundColor(.secondary)
                            .frame(height: 20)
                            .onTapGesture {
                                openDict(wordStats.word!)
                            }
                            .id(wordStats)
                    }
                }
                
                Section(header: Text("Familiar Words Count: \(xFamiliarWordStatss.count)")) {
                    ForEach(xFamiliarWordStatss, id: \.self) { wordStats in
                        Text("\(wordStats.word!): \(wordStats.presentCount)")
                            .foregroundColor(.secondary)
                            .frame(height: 20)
                            .onTapGesture {
                                openDict(wordStats.word!)
                            }
                            .id(wordStats)
                    }
                }
            }
        }
    }
}

let familiarThreshold = 50 // todo: make this value customiziable from UI

func openDict(_ word: String) {
    let task = Process()
    task.launchPath = "/usr/bin/open"
    var arguments = [String]();
    arguments.append("dict://\(word)")
    task.arguments = arguments
    task.launch()
}

struct HistoryWordsView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryWordsView()
    }
}
