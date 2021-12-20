//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/24.
//

import SwiftUI

struct WordsView: View {
    @EnvironmentObject var displayedWords: DisplayedWords

    var body: some View {
        ForEach(displayedWords.wordCells) {
            SingleWordView(wordCell: $0.wordCell).id($0.id)
        }
    }
}
