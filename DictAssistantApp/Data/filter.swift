//
//  filter.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/3.
//

import Foundation

func read(_ filename: String) -> Set<String> {
    guard let path = Bundle.main.path(forResource: filename, ofType: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        return Set(content.components(separatedBy: "\n"))
    }
    catch(_) {
        fatalError("Couldn't init from \(filename)")
    }
}

func genChars() -> Set<Character> {
    let str = "a b c d e f g h i j k l m n o p q r s t u v w x y z"
    let s = str.components(separatedBy: " ")
    let s2 = s.map{ Character($0) }
    return Set(s2)
}

