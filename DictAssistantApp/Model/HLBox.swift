//
//  HLBox.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/12.
//

import Foundation

struct IndexedBox: Identifiable, Equatable {
    let box: (CGPoint, CGPoint)
    let index: Int
    var id = UUID()
    
    static func ==(lhs: IndexedBox, rhs: IndexedBox) -> Bool {
        return lhs.box == rhs.box
    }
}

class HLBox: ObservableObject {
    @Published var indexedBoxes: [IndexedBox]
    
    init(indexedBoxes: [IndexedBox]) {
        self.indexedBoxes = indexedBoxes
    }
}

let hlBox = HLBox(indexedBoxes: [])
