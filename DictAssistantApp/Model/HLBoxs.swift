//
//  HLBox.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/12.
//

import Foundation

class HLBoxs: ObservableObject {
    @Published var boxs: [(CGPoint, CGPoint)]
    
    init(boxs: [(CGPoint, CGPoint)]) {
        self.boxs = boxs
    }
}

let hlBox = HLBoxs(boxs: [])
