//
//  Searchable.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation
import DataBases

func isLookUpable(_ word: String) -> Bool {
    return smallDictionary[word] != nil
}

func translate(_ word: String) -> String {
    return smallDictionary[word]!
}
