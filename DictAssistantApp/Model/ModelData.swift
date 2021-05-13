//
//  ModelData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/30.
//

import Foundation
import Combine
import Cocoa
import DataBases

class ModelData: ObservableObject {
    @Published var words = [ // can't be empty; otherwise WordsView not displayed!!
        Word(
            text: "favorite",
            existence: true,
            knowable: true,
            translation: "最爱的",
            isTranslationFromDictionaryServices: false),
        Word(
            text: "stays",
            existence: true,
            knowable: true,
            translation: "A.intransitive verb (remain in place) 停留 tíngliú",
            isTranslationFromDictionaryServices: true),
    ]
}
