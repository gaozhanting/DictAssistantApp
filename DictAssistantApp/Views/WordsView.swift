//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/22.
//

import SwiftUI
import DataBases

// no use, continue ...
struct WordsView: View {
//    @EnvironmentObject var recognizedText: RecognizedText
//    @Environment(\.managedObjectContext) var managedObjectContext
//    @FetchRequest(
//        entity: WordStats.entity(),
//        sortDescriptors: [],
//        predicate: NSPredicate(format: "presentCount >= \(familiarThreshold)")
//    ) var familiarWordStatss: FetchedResults<WordStats>
    
//    @State var fontSize: CGFloat = 24
    
//    var familiarWords: [String] {
//        familiarWordStatss.map { $0.word! }
//    }
//
//    var familiarWordsSet: Set<String> {
//        Set(familiarWords)
//    }
//
//    var words: [Word] {
//        modelData.words
//    }
//
//    var foundWordsFromServices: [Word] {
//        words.filter { ($0.translation != nil) && !familiarWordsSet.contains($0.text) && $0.isTranslationFromDictionaryServices  }
//    }
//
//    var notFoundWords: [Word] {
//        words.filter { $0.translation == nil }
//    }
    
    var body: some View {
//        SimpleWordsView()
        Text("WordsView")
    }
}




//struct WordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        WordsView().environmentObject(RecognizedText(
//            texts: ["Tomorrow - A mystical land where 99% of all human productivity, motivation and achievement are stored"]
//        ))
//    }
//}
