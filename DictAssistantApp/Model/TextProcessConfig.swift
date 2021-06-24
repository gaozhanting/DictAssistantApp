//
//  TextProcessConfig.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/31.
//

import Foundation
import Vision

class TextProcessConfig: ObservableObject {
    @Published var textRecognitionLevelInner: VNRequestTextRecognitionLevel
    
    var textRecognitionLevel: VNRequestTextRecognitionLevel {
        get {
            textRecognitionLevelInner
        }
        set {
            textRecognitionLevelInner = newValue
            setSideEffectCode()
        }
    }
    
    var setSideEffectCode: () -> Void

    
    init(textRecognitionLevelInner: VNRequestTextRecognitionLevel, setSideEffectCode: @escaping () -> Void) {
        self.textRecognitionLevelInner = textRecognitionLevelInner
        self.setSideEffectCode = setSideEffectCode
    }
}
