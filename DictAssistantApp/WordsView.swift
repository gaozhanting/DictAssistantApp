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
            
            Spacer()
            Text("found")
            ForEach(modelData.foundEnZh, id: \.self) { foundEnZh in
                Text(foundEnZh)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            Text("not found")
            ForEach(modelData.notFound, id: \.self) { notFound in
                Text(notFound)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            Text("basic")
            ForEach(modelData.basic, id: \.self) { ba in
                Text(ba)
                    .foregroundColor(.secondary)
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

