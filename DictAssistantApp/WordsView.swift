//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/22.
//

import SwiftUI

struct WordsView: View {
    @ObservedObject var modelData: ModelData

    var body: some View {
        List {
            Text("count = \(modelData.words.count)")
                .foregroundColor(.yellow)
            ForEach(modelData.words, id: \.self) { words in
                Text(words)
                    .foregroundColor(.white)
//                    .background(Color.gray)
            }
        }
    }
}

struct WordsView_Previews: PreviewProvider {
    static let modelData = ModelData()

    static var previews: some View {
        WordsView(modelData: modelData)
    }
}

