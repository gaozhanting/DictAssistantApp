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
    
    init(textRecognitionLevel: VNRequestTextRecognitionLevel) {
        self.textRecognitionLevel = textRecognitionLevel
    }
}
