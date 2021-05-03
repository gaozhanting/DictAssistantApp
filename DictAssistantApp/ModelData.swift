//
//  ModelData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/30.
//

import Foundation
import Combine

class ModelData: ObservableObject {
    @Published var words = [ // can't be empty; otherwise WordsView not displayed!!
        "favorite",
        "beauty",
        "POST",
        "information.",
        "",
        "customers,",
        "saying",
        "app",
        "ications"
    ]
  
// later use this
//    var prefixSixWords: ArraySlice<String> {
//        return words.prefix(6)
//    }
}
