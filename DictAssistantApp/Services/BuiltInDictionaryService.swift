//
//  InnerDictionaryService.swift
//  DictAssistantApp Zh_S
//
//  Created by Gao Cong on 2021/11/27.
//

import Foundation

func builtInDefine(_ word: String) -> String? {
    if let remoteEntry = getRemoteEntry(of: word) {
        return "\(remoteEntry.word!) \(remoteEntry.trans!)"
    } else {
        return nil
    }
}
