//
//  DictionaryService.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation

// cachedDict is useful when using Apple Dict
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
        return mixDefine(word)
    case .asFirstPriority:
        if let trans = queryEntry(word: word) {
            return trans
        }
        return mixDefine(word)
    case .asLastPriority:
        if let trans = mixDefine(word) {
            return trans
        }
        return queryEntry(word: word)
    case .only:
        return queryEntry(word: word)
    }
}

private func mixDefine(_ word: String) -> String? {
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

private func queryEntry(word: String) -> String? {
    if let trans = entriesDict[word] {
        return "\(word)\(trans)"
    }
    return nil
}
