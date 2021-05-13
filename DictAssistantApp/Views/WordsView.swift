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
    
    var foundWords: [String] {
        words
            .filter { $0.translation != nil }
            .map { word in
                "\(word.text): \(word.translation!)"
            }
    }
    
    var notFoundWords: [Word] {
        words.filter { $0.translation == nil }
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
                    .frame(height: 20)
            }
            
            Spacer()
            Text(">NotFoundWords:")
                .foregroundColor(.yellow)
            ForEach(notFoundWords, id: \.self) { word in
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

