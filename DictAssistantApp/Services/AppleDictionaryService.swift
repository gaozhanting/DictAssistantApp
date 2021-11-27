//
//  AppleDictionaryService.swift
//  DictAssistantApp Zh_S
//
//  Created by Gao Cong on 2021/11/27.
//

import Foundation
import CoreServices.DictionaryServices

func appleDefine(_ word: String) -> String? {
    let nsstring = word as NSString
    let cfrange = CFRange(location: 0, length: nsstring.length)
    
    guard let definition = DCSCopyTextDefinition(nil, nsstring, cfrange) else {
        return nil
    }
    
    let whole = String(definition.takeUnretainedValue())
    return whole
}
