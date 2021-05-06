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
            Text(">>>Translations:")
                .foregroundColor(.yellow)
            ForEach(modelData.translations, id: \.self) { info in
                Text(info)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            Text(">>>UnLookupableWords:")
                .foregroundColor(.yellow)
            ForEach(modelData.unLookupableWords, id: \.self) { info in
                Text(info)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            Text(">>>KnownWords:")
                .foregroundColor(.yellow)
            ForEach(modelData.knownWords, id: \.self) { info in
                Text(info)
                    .foregroundColor(.secondary)
            }
            
//            Spacer()
//            ForEach(modelData.translations, id: \.self) { info in
//                Text(info)
//                    .foregroundColor(.secondary)
//            }
//
//            Spacer()
//            ForEach(modelData.translations, id: \.self) { info in
//                Text(info)
//                    .foregroundColor(.secondary)
//            }
//
//            Spacer()
//            ForEach(modelData.translations, id: \.self) { info in
//                Text(info)
//                    .foregroundColor(.secondary)
//            }

//            Spacer()
//            Text("Not found:")
//            ForEach(modelData.notFound, id: \.self) { notFound in
//                Text(notFound)
//                    .foregroundColor(.secondary)
//            }
//
//            Spacer()
//            Text("Basic:")
//            ForEach(modelData.basic, id: \.self) { ba in
//                Text(ba)
//                    .foregroundColor(.secondary)
//            }
        }
    }
}



struct WordsView_Previews: PreviewProvider {
    static let modelData = ModelData()
    
    static var previews: some View {
        WordsView(modelData: modelData)
    }
}

