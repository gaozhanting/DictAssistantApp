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
    
    var words: [SingleClassifiedText] {
        modelData.words
    }
    
    var highSchoolWords: [SingleClassifiedText] {
        words.filter { highSchoolVocabulary.contains($0.text) }
    }
    
    var beyondHighSchoolWords: [SingleClassifiedText] {
        words.filter { !highSchoolVocabulary.contains($0.text) }
    }
    
    var foundWords: [String] {
        beyondHighSchoolWords
            .filter { smallDictionary[$0.text] != nil }
            .map { word in
                let text = word.text
                return "\(text): \(smallDictionary[text]!)"
            }
    }
    
    var notFoundWords: [SingleClassifiedText] {
        beyondHighSchoolWords.filter { smallDictionary[$0.text] == nil }
    }
    
    var body: some View {
        List {
            Text("count = \(words.count)")
                .foregroundColor(.yellow)
            
            Spacer()
            Text(">FoundWords:")
                .foregroundColor(.yellow)
            ForEach(foundWords, id: \.self) { word in
                Text(word)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            Text(">NotFoundWords:")
                .foregroundColor(.yellow)
            ForEach(notFoundWords, id: \.self) { word in
                Text(word.text)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            Text(">HighSchoolWords:")
                .foregroundColor(.yellow)
            ForEach(highSchoolWords, id: \.self) { word in
                Text(word.text)
                    .foregroundColor(.secondary)
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

