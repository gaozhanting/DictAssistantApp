//
//  CropData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/31.
//

import Foundation
import Combine

class CropData: ObservableObject {
    @Published var x: CGFloat = 200
    @Published var y: CGFloat = 100
    @Published var width: CGFloat = 400
    @Published var height: CGFloat = 200
}
