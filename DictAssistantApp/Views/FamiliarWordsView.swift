//
//  FamiliarWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/19.
//

import SwiftUI

struct FamiliarWordsView: View {
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordStats.presentCount, ascending: true)
        ],
        predicate: NSPredicate(format: "presentCount >= \(familiarThreshold)")
    ) var wordStatss: FetchedResults<WordStats>
    
    var body: some View {
        ForEach(wordStatss, id: \.self) { wordStats in
            Text("\(wordStats.word!): \(wordStats.presentCount)")
                .foregroundColor(.secondary)
                .frame(height: 20)
        }
    }
}

//struct FamiliarWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        FamiliarWordsView(familiarWordStats: [
//            WordStats(word: "word1", presentCount: 1)
//        ])
//    }
//}
