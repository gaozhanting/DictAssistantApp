//
//  StatusData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/20.
//

import Foundation

class StatusData: ObservableObject {
    @Published var isPlaying: Bool
    
    init(isPlaying: Bool) {
        self.isPlaying = isPlaying
    }
}

let statusData = StatusData(isPlaying: false)
