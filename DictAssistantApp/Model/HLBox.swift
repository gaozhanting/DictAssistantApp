//
//  HLBox.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/12.
//

import Foundation

struct IndexedBox: Identifiable {
    let box: (CGPoint, CGPoint)
    let index: Int
    var id = UUID()
}

class HLBox: ObservableObject {
    @Published var indexedBoxes: [IndexedBox]
    
    init(indexedBoxes: [IndexedBox]) {
        self.indexedBoxes = indexedBoxes
    }
}

let hlBox = HLBox(indexedBoxes: [])
