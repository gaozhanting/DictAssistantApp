//
//  UnFamiliarWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/19.
//

import SwiftUI

struct UnFamiliarWordsView: View {
    @FetchRequest(
        entity: WordStats.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WordStats.presentCount, ascending: true)
        ],
        predicate: NSPredicate(format: "presentCount < \(familiarThreshold)")
    ) var wordStatss: FetchedResults<WordStats>
    
    var body: some View {
        ForEach(wordStatss, id: \.self) { wordStats in
            Text("\(wordStats.word!): \(wordStats.presentCount)")
                .foregroundColor(.secondary)
                .frame(height: 20)
        }
    }
}

//struct UnFamiliarWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        UnFamiliarWordsView()
//    }
//}
