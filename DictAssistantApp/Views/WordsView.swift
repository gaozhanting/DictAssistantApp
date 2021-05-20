//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/22.
//

import SwiftUI
import DataBases

let familiarThreshold = 50 // todo: make this value customiziable from UI

struct WordsView: View {
    @ObservedObject var modelData: ModelData
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "presentCount >= \(familiarThreshold)")
    ) var familiarWordStatss: FetchedResults<WordStats>
    
    var familiarWords: [String] {
        familiarWordStatss.map { $0.word! }
    }
    
    var familiarWordsSet: Set<String> {
        Set(familiarWords)
    }
    
    var words: [Word] {
        modelData.words
    }
    
    var foundWords: [Word] {
        words.filter { ($0.translation != nil) && !$0.isTranslationFromDictionaryServices  }
    }
    
    var foundWordsFromServices: [Word] {
        words.filter { ($0.translation != nil) && !familiarWordsSet.contains($0.text) && $0.isTranslationFromDictionaryServices  }
    }
    
    var notFoundWords: [Word] {
        words.filter { $0.translation == nil }
    }
    
    @State private var toggleFamiliarWordsView = false
    @State private var toggleUnFamiliarWordsView = false
        
    var body: some View {

        List {
            Text("count = \(words.count)")
                .foregroundColor(.yellow)
            
            Group {
                Text("FoundWords:")
                    .foregroundColor(.yellow)
                ForEach(foundWords, id: \.self) { word in
                    HStack {
                        Text(word.text)
                            .foregroundColor(.green)
                        Text(word.translation!)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 20)
                }
            }
            
            Group {
                Text("FoundWordsFromServices:")
                    .foregroundColor(.yellow)
                ForEach(foundWordsFromServices, id: \.self) { word in
                    VStack(alignment: .leading) {
                        Text(word.text)
                            .foregroundColor(.green)
                        Text(word.translation!)
                            .foregroundColor(.secondary)
                            .frame(maxHeight: 60)
                    }
                }
            }

            Group {
                Text("NotFoundWords:")
                    .foregroundColor(.yellow)
                ForEach(notFoundWords, id: \.self) { word in
                    Text(word.text)
                        .foregroundColor(.secondary)
                        .frame(height: 20)
                }
            }
            
            Toggle(isOn: $toggleUnFamiliarWordsView) {
                Text("See UnFamiliar Words")
            }
            if toggleUnFamiliarWordsView {
                UnFamiliarWordsView()
            }
            
            Toggle(isOn: $toggleFamiliarWordsView) {
                Text("See Familiar Words")
            }
            if toggleFamiliarWordsView {
                FamiliarWordsView()
            }
        
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    


}



struct WordsView_Previews: PreviewProvider {
    static let modelData = ModelData()
    
    static var previews: some View {
        WordsView(modelData: modelData)
    }
}

