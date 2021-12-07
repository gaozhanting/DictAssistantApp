//
//  DictionaryService.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation

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
    let mode = UseEntryMode.init(rawValue: UserDefaults.standard.integer(forKey: UseEntryModeKey))!
    switch mode {
    case .notUse:
        return mixDefine(word)
    case .asFirstPriority:
        if let trans = customDefine(word: word) {
            return trans
        }
        return mixDefine(word)
    case .asLastPriority:
        if let trans = mixDefine(word) {
            return trans
        }
        return customDefine(word: word)
    case .only:
        return customDefine(word: word)
    }
}

func mixDefine(_ word: String) -> String? {
    let mode = UseAppleDictMode.init(rawValue: UserDefaults.standard.integer(forKey: UseAppleDictModeKey))!
    switch mode {
    case .notUse:
        return builtInDefine(word)
    case .afterBuiltIn:
        if let trans = builtInDefine(word) {
            return trans
        }
        return appleDefine(word)
    case .beforeBuiltIn:
        if let trans = appleDefine(word) {
            return trans
        }
        return builtInDefine(word)
    case .only:
        return appleDefine(word)
    }
}

func builtInDefine(_ word: String) -> String? {
    if let remoteEntry = getRemoteEntry(of: word) {
        // DictionaryServices trans all includes the title word, simulate Apple Dictionary behavior, for consistence for content options.
        return "\(remoteEntry.word!) \(remoteEntry.trans!)"
    } else {
        return nil
    }
}

func customDefine(word: String) -> String? {
    if let customEntry = getCustomEntry(of: word) {
        return "\(customEntry.word!) \(customEntry.trans!)"
    }
    return nil
}
