//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/24.
//

import SwiftUI

struct WordsView: View {
    @EnvironmentObject var displayedWords: DisplayedWords
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true // the value only used when the key doesn't exists, this will never be the case because we init it when app lanched
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    @AppStorage(IsShowCurrentKnownButWithOpacity0Key) private var isShowCurrentKnownButWithOpacity0: Bool = false

    var words: [WordCellWithId] {
        convertToWordCellWithId(from: displayedWords.wordCells, isShowPhrase: isShowPhrase, isShowCurrentKnown: isShowCurrentKnown, isShowCurrentKnownButWithOpacity0: isShowCurrentKnownButWithOpacity0)
    }
    
    var body: some View {
        ForEach(words) { wordCellWithId in
            let wordCell = wordCellWithId.wordCell
            SingleWordView(wordCell: wordCell)
        }
    }
}

func convertToWordCellWithId(from primitiveWordCells: [WordCell], isShowPhrase: Bool, isShowCurrentKnown: Bool, isShowCurrentKnownButWithOpacity0: Bool) -> [WordCellWithId] {
    let wordCells: [WordCell] = isShowPhrase ?
        primitiveWordCells :
        primitiveWordCells.filter { !$0.word.contains(" ") }
    
    if isShowCurrentKnown || isShowCurrentKnownButWithOpacity0 {
        var attachedId: [WordCellWithId] = []
        var auxiliary: [String:Int] = [:]
        for wordCell in wordCells {
            let word = wordCell.word
            auxiliary[word, default: 0] += 1
            let id = "\(word)_\(auxiliary[word]!)"
            attachedId.append(WordCellWithId(wordCell: wordCell, id: id))
        }
        return attachedId
    }
    else {
        var deDuplicated: [WordCellWithId] = []
        var auxiliary: Set<String> = Set.init()
        for wordCell in wordCells {
            let word = wordCell.word
            if !auxiliary.contains(word) {
                deDuplicated.append(WordCellWithId(wordCell: wordCell, id: word))
                auxiliary.insert(word)
            }
        }
        let removeKnownRemoveTransEmpty = deDuplicated.filter{ $0.wordCell.isKnown == .unKnown && !$0.wordCell.trans.isEmpty }
        return removeKnownRemoveTransEmpty
    }
}

//struct WordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        WordsView()
//    }
//}
