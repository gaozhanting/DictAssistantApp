//
//  StatusData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/20.
//

import Foundation

class StatusData: ObservableObject {
    @Published private var isPlayingInner: Bool
    
    var setSideEffectCode: () -> Void
    
    var isPlaying: Bool {
        get {
            isPlayingInner
        }
        set {
            isPlayingInner = newValue
            setSideEffectCode()
        }
    }
    
    init(isPlayingInner: Bool, sideEffectCode: @escaping () -> Void) {
        self.isPlayingInner = isPlayingInner
        self.setSideEffectCode = sideEffectCode
    }
}
