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
    
    var filteredUnFamiliarWordStatss: [WordStats] {
        switch bar {
        case .filter:
            return unFamiliarWordStatss.filter { wordStats in
                wordStats.presentCount >= low
            }
        case .search:
            return unFamiliarWordStatss.filter { wordStats in
                wordStats.word == searchedWord
            }
        }
    }
    
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordStats.presentCount, ascending: true)
        ],
        predicate: NSPredicate(format: "presentCount >= \(familiarThreshold)")
    ) var familiarWordStatss: FetchedResults<WordStats>
    
    var filteredFamiliarWordStatss: [WordStats] {
        switch bar {
        case .filter:
            return familiarWordStatss.filter { wordStats in
                wordStats.presentCount >= low
            }
        case .search:
            return familiarWordStatss.filter { wordStats in
                wordStats.word == searchedWord
            }
        }
    }

    @State fileprivate var bar: Bar = .filter
    
    // filter bar
    @State var low: Int = 1
    
    // search bar
    @State private var searchedWord: String = ""
    
    var body: some View {
        List {
            Section(
                header:
                    VStack(alignment: .leading) {
                        Text("All Words Count: \(unFamiliarWordStatss.count + familiarWordStatss.count)")
                        
                        switch bar {
                        case .filter:
                            FilterBar(low: $low, bar: $bar)
                        case .search:
                            SearchBar(searchedWord: $searchedWord, bar: $bar)
                        }
                    }
            ) {}
            
            Section(header: Text("UnFamiliar Words Count: \(filteredUnFamiliarWordStatss.count)")) {
                ForEach(filteredUnFamiliarWordStatss, id: \.self) { wordStats in
                    Text("\(wordStats.word!): \(wordStats.presentCount)")
                        .foregroundColor(.secondary)
                        .frame(height: 20)
                        .onTapGesture {
                            openDict(wordStats.word!)
                        }
                        .id(wordStats)
                }
            }
            
            Section(header: Text("Familiar Words Count: \(filteredFamiliarWordStatss.count)")) {
                ForEach(filteredFamiliarWordStatss, id: \.self) { wordStats in
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

fileprivate enum Bar {
    case filter
    case search
}

struct FilterBar: View {
    @Binding var low: Int
    @Binding fileprivate var bar: Bar

    let step = 1
    let range = 1...(familiarThreshold * 10)
    
    let halfFamiliarThreshold: Int = familiarThreshold / 2
    let one: Int = 1
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    bar = .search
                }
            }, label: {
                Image(systemName: "arrow.2.squarepath")
            })
            .buttonStyle(PlainButtonStyle())
            
            Text("Filter:")
            
            Spacer()
                        
            // preset for convenience
            Button(action: { low = one }, label: { Text("\(one)") })
            Button(action: { low = halfFamiliarThreshold }, label: { Text("\(halfFamiliarThreshold)") })
            Button(action: { low = familiarThreshold }, label: { Text("\(familiarThreshold)").foregroundColor(Color.accentColor) })
            Button(action: { low = familiarThreshold * 2 }, label: { Text("\(familiarThreshold * 2)") })
            Button(action: { low = familiarThreshold * 4 }, label: { Text("\(familiarThreshold * 4)") })
            Button(action: { low = familiarThreshold * 8 }, label: { Text("\(familiarThreshold * 8)") })

            Stepper(value: $low,
                    in: range,
                    step: step) {
                Text("\(low)")
            }
        }
    }
}

struct SearchBar: View {
    @Binding var searchedWord: String
    @Binding fileprivate var bar: Bar
    
    @State private var eSearchedWord: String = ""
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    bar = .filter
                }
            }, label: {
                Image(systemName: "arrow.2.squarepath")
            })
            .buttonStyle(PlainButtonStyle())
            
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
}

let familiarThreshold: Int = 100 // todo: make this value customiziable from UI

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
