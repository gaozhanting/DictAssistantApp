//
//  Searchable.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation
import DataBases

func translate(_ word: String) -> String? {
    return smallDictionary[word]
}
