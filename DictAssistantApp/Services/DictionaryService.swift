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

func queryDefine(_ word: String) -> String? {
    let mode = UseCustomDictMode.init(rawValue: UserDefaults.standard.integer(forKey: UseCustomDictModeKey))!
    switch mode {
    case .notUse:
        return DictionaryServices.define(word)
    case .asFirstPriority:
        if let entry = getEntry(of: word) {
            let entryStr = "\(entry.word!)\(entry.trans!)"
            return entryStr
        }
        return DictionaryServices.define(word)
    case .asLastPriority:
        if let define = DictionaryServices.define(word) {
            return define
        }
        if let entry = getEntry(of: word) {
            let entryStr = "\(entry.word!)\(entry.trans!)"
            return entryStr
        }
        return nil
    case .only:
        if let entry = getEntry(of: word) {
            let entryStr = "\(entry.word!)\(entry.trans!)"
            return entryStr
        }
        return nil
    }
}
