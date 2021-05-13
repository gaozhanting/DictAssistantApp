//
//  File.swift
//  
//
//  Created by Gao Cong on 2021/5/14.
//

import Foundation
import CoreServices.DictionaryServices

public struct DictionaryServices {
    // from DictionaryServices (MUST install dict at built-in Dictioanry App)
    public static func define(_ word: String) -> String? {
        let nsstring = word as NSString
        let cfrange = CFRange(location: 0, length: nsstring.length)

        guard let definition = DCSCopyTextDefinition(nil, nsstring, cfrange) else {
            return nil
        }

        let whole = String(definition.takeUnretainedValue())
        
        let parts = whole.split(separator: "|")
        // if whole has phonetic symbol; parts will has 3 part
        if 2 < parts.count {
            let translation = String(parts[2])
            return translation
        }
        return whole
    }
}
