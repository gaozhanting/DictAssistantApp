//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/22.
//

import SwiftUI
import DataBases

struct WordsView: View {
    @ObservedObject var modelData: ModelData
    
    var words: [Word] {
        modelData.words
    }
    
    var foundWords: [Word] {
        words.filter { ($0.translation != nil) && !$0.isTranslationFromDictionaryServices  }
    }
    
    var foundWordsFromServices: [Word] {
        words.filter { ($0.translation != nil) && $0.isTranslationFromDictionaryServices  }
    }
    
    var notFoundWords: [Word] {
        words.filter { $0.translation == nil }
    }
        
    var body: some View {
        List {
            Text("count = \(words.count)")
                .foregroundColor(.yellow)
            
            Spacer()
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
                .frame(maxHeight: 80)
            }
            
            Spacer()
            Text("NotFoundWords:")
                .foregroundColor(.yellow)
            ForEach(notFoundWords, id: \.self) { word in
                Text(word.text)
                    .foregroundColor(.secondary)
                    .frame(height: 20)
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

