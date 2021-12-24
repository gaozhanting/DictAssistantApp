//
//  SettingsCommon.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/24.
//

import Foundation

let tfWidth: CGFloat = 46
let tfSmallWidth: CGFloat = 30
let tfDecimalFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    return f
}()
let tfIntegerFormatter = NumberFormatter()
