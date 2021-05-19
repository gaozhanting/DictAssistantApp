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
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptor: [
            NSSortDescriptor(keyPath: \WordStats.count, ascending: true)
        ]
    ) var wordPresentCounts: FetchedResults<WordStats>
    
    @FetchRequest(
      // 2.
      entity: Movie.entity(),
      // 3.
      sortDescriptors: [
        NSSortDescriptor(keyPath: \Movie.title, ascending: true)
      ]
      //,predicate: NSPredicate(format: "genre contains 'Action'")
      // 4.
    ) var movies: FetchedResults<Movie>
    
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
            
            Spacer()
            Text("FoundWordsFromServices:")
                .foregroundColor(.yellow)
            ForEach(foundWordsFromServices, id: \.self) { word in
//                HStack(alignment: .firstTextBaseline) {
//                    VStack {
//                        Text(word.text)
//                            .foregroundColor(.green)
//                            .frame(height: 20)
//                    }
//                    VStack {
//                        Text(word.translation!)
//                            .foregroundColor(.secondary)
//                            .frame(maxHeight: 60)
//                    }
//                }
                
                VStack(alignment: .leading) {
                    Text(word.text)
                        .foregroundColor(.green)
                    Text(word.translation!)
                        .foregroundColor(.secondary)
                        .frame(maxHeight: 60)
                }
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

