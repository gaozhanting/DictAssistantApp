//
//  HLBox.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/12.
//

import Foundation

class HLBox: ObservableObject {
    @Published var box: (CGPoint, CGPoint, CGPoint, CGPoint)
    
    init(box: (CGPoint, CGPoint, CGPoint, CGPoint)) {
        self.box = box
    }
}

let hlBox = HLBox(box: (CGPoint(x: 0,y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 0)))
