//
//  ModelData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/30.
//

import Foundation
import Combine
import Cocoa
import DataBases

class ModelData: ObservableObject {
    @Published var words = [ // can't be empty; otherwise WordsView not displayed!!
        SingleClassifiedText(text: "favorite", existence: true, knowable: true, lookupable: true, translation: "最爱的"),
//        SingleClassifiedText(text: "-", existence: true, knowable: true, lookupable: false),
//        "beauty",
//        "information",
//        "",
//        "best-seller",
//        "post",
//        "customers",
//        "saying",
//        "app",
//        "caption"
    ]
    
    var nonExistenceWords: [String] {
        words.filter { !$0.existence }
             .map { $0.text }
    }
    
    var knownWords: [String] {
        words.filter { $0.existence }
             .filter { $0.knowable }
             .map { $0.text }
    }
    
    var unLookupableWords: [String] {
        words.filter { $0.existence }
             .filter { !$0.knowable }
             .filter { !$0.lookupable }
             .map { $0.text }
    }
    
    var translations: [String] {
        words.filter { $0.existence }
             .filter { !$0.knowable }
             .filter { $0.lookupable }
             .map { "\($0.text): \($0.translation)" }
    }
    
//
//    func del() -> AppDelegate {
//        return NSApplication.shared.delegate as! AppDelegate
//    }
//
//    var foundEnZh: [String] {
//        var result: [String] = []
//        for word in notBasic {
//            if let zh = azureDictionary[word] {
//                result.append("\(word): \(zh)")
//            }
//        }
//        return result
//    }
//
//    var notFound: [String] {
//        var result: [String] = []
//        for word in notBasic {
//            if azureDictionary[word] == nil {
//                result.append(word)
//            }
//        }
//        return result
//    }
    
//    var foundEnZh: [String] {
//        var result: [String] = []
//        for word in notBasic {
//            if let zh = basicDict[word] {
//                result.append("\(word): \(zh)")
//            }
//        }
//        return result
//    }
//
//    var notFound: [String] {
//        var result: [String] = []
//        for word in notBasic {
//            if basicDict[word] == nil {
//                result.append(word)
//            }
//        }
//        return result
//    }

//    var notBasic: [String] {
//        var result: [String] = []
//        for word in words {
//            if highSchoolVocabulary.contains(word) {
//                result.append(word)
//            }
//        }
//        return result
//    }
//
//    var basic: [String] {
//        var result: [String] = []
//        for word in words {
//            if highSchoolVocabulary.contains(word) {
//                result.append(word)
//            }
//        }
//        return result
//    }
    
}

//struct EnZh: Hashable {
//    let en: String
//    let zh: String
//}
    
