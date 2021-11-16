//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/24.
//

import SwiftUI

struct WordsView: View {
    @EnvironmentObject var displayedWords: DisplayedWords
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    @AppStorage(IsShowCurrentKnownButWithOpacity0Key) private var isShowCurrentKnownButWithOpacity0: Bool = false
    @AppStorage(IsShowCurrentNotFoundWordsKey) private var isShowCurrentNotFoundWords: Bool = false

    var words: [WordCellWithId] {
        convertToWordCellWithId(
            from: displayedWords.wordCells,
            isShowCurrentKnown: isShowCurrentKnown,
            isShowCurrentKnownButWithOpacity0: isShowCurrentKnownButWithOpacity0,
            isShowCurrentNotFoundWords: isShowCurrentNotFoundWords)
    }
    
    var body: some View {
        ForEach(words) { wordCellWithId in
            let wordCell = wordCellWithId.wordCell
            SingleWordView(wordCell: wordCell).id(wordCellWithId.id)
        }
    }
}

struct WordCellWithId: Identifiable, Equatable {
    let wordCell: WordCell
    let id: String
}

func convertToWordCellWithId(
    from primitiveWordCells: [WordCell],
    isShowCurrentKnown: Bool,
    isShowCurrentKnownButWithOpacity0: Bool,
    isShowCurrentNotFoundWords: Bool
) -> [WordCellWithId] {
    let wordCells: [WordCell] = !isShowCurrentNotFoundWords ? // default false
    primitiveWordCells.filter { !($0.isKnown == .unKnown && $0.trans.isEmpty) } :
    primitiveWordCells
    
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
    
    var deDuplicated: [WordCellWithId] = []
    var auxiliary: Set<String> = Set.init()
    for wordCell in wordCells {
        let word = wordCell.word
        if !auxiliary.contains(word) {
            deDuplicated.append(WordCellWithId(wordCell: wordCell, id: word))
            auxiliary.insert(word)
        }
    }
    return deDuplicated.filter{ $0.wordCell.isKnown == .unKnown }
}

//struct WordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        WordsView()
//    }
//}
