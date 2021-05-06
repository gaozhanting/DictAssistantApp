//
//  Classification.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation

struct SingleClassifiedText: Hashable {
    var text: String
    var existence: Bool // true if the word a valid English word
    var knowable: Bool // true if the word I know
    var lookupable: Bool // true if the word can dict
    var translation: String // the (Chinese) translation of the (English) word
    
    // how to add assertion of this struct
    // e.g: asset translation is nil if existence is false
}
