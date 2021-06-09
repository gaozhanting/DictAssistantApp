//
//  CropData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/31.
//

import Foundation

class CropData: ObservableObject {
    @Published var x: CGFloat
    @Published var y: CGFloat
    @Published var width: CGFloat
    @Published var height: CGFloat
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}
