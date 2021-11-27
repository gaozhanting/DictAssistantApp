//
//  InnerDictionaryService.swift
//  DictAssistantApp Zh_S
//
//  Created by Gao Cong on 2021/11/27.
//

import Foundation

var currentEntries: Dictionary<String, String> = getAllZhSEntries()
func builtInDefine(_ word: String) -> String? {
    return currentEntries[word]
}
