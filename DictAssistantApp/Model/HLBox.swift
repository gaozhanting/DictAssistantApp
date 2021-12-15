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
    var id: CGPoint {
        self.box.0
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

class HLBox: ObservableObject {
    @Published var indexedBoxes: [IndexedBox]
    
    init(indexedBoxes: [IndexedBox]) {
        self.indexedBoxes = indexedBoxes
    }
}

let hlBox = HLBox(indexedBoxes: [])
