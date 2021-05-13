//
//  Classification.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation

struct Word: Hashable {
    var text: String
    var existence: Bool // true if the word a valid English word
    var knowable: Bool // true if the word I know
    var translation: String? // the (Chinese) translation of the (English) word; nil if can't found the translation
    var isTranslationFromDictionaryServices: Bool // true when translation is not nil and comes from using Dict Services
    
    // how to add assertion of this struct
    // e.g: asset translation is nil if existence is false
}
