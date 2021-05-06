//
//  Knowable.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation
import DataBases

func isKnowable(_ word: String) -> Bool {
    return highSchoolVocabulary.contains(word)
}
