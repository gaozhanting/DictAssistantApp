//
//  SimpleWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/7.
//

import SwiftUI
import DataBases

struct SimpleWordsView: View {
    
    let words: [String]
    
    func translation(of word: String) -> String {
        if let tr = DictionaryServices.define(word) {
            return tr
        } else {
            return ""
        }
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 10.0) {
                ForEach(words, id: \.self) { word in
                    (Text(word).foregroundColor(.orange)
                        + Text(translation(of: word)).foregroundColor(.white))
                        .font(.system(size: 25))
                        .onTapGesture {
                            openDict(word)
                        }
                        .frame(maxWidth: 250)
                }
            }
        }
    }
}

struct SimpleWordsView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleWordsView(
            words: [
                "beautiful",
                "brave",
                "braw",
                "entitle",
                "goblin",
                "elf"
            ]
        )
    }
}
