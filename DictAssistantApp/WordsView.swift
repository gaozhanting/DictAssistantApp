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
        VStack {
            ForEach(Array(modelData.words).prefix(6), id: \.self) { words in
                Text(words)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.green)
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

