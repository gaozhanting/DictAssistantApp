//
//  TextProcessConfig.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/31.
//

import Foundation
import Vision

class TextProcessConfig: ObservableObject {
    @Published var textRecognitionLevel: VNRequestTextRecognitionLevel
    @Published var minimumTextHeight: Float

    init(textRecognitionLevel: VNRequestTextRecognitionLevel, minimumTextHeight: Float) {
        self.textRecognitionLevel = textRecognitionLevel
        self.minimumTextHeight = minimumTextHeight
    }
}
