//
//  SmallConfig.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/14.
//

import Foundation

class SmallConfig: ObservableObject {
    @Published var fontRate: CGFloat // transFontSize / wordFontSize
    @Published var addLineBreak: Bool
    
    init(fontRate: CGFloat, addLineBreak: Bool) {
        self.fontRate = fontRate
        self.addLineBreak = addLineBreak
    }
}
