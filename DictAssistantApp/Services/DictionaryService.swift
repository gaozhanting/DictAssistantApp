//
//  DictionaryService.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import DataBases

var cachedDict: [String: String?] = [:]

func cachedDictionaryServicesDefine(_ word: String) -> String? {
    if let trans = cachedDict[word] {
        return trans
    }
    let trans = queryDefine(word)
    cachedDict[word] = trans
    return trans
}

private func queryDefine(_ word: String) -> String? {
    let mode = UseEntryMode.init(rawValue: UserDefaults.standard.integer(forKey: UseEntryModeKey))!
    switch mode {
    case .notUse:
        return DictionaryServices.define(word)
    case .asFirstPriority:
        if let entry = queryEntry(word: word) {
            return entry
        }
        return DictionaryServices.define(word)
    case .asLastPriority:
        if let define = DictionaryServices.define(word) {
            return define
        }
        return queryEntry(word: word)
    case .only:
        return queryEntry(word: word)
    }
}

private func queryEntry(word: String) -> String? {
    if let trans = entriesDict[word] {
        return "\(word)\(trans)"
    }
    return nil
}
