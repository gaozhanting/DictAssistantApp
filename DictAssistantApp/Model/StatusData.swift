//
//  StatusData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/20.
//

import Foundation

class StatusData: ObservableObject {
    @Published var isPlaying: Bool = false
    
    init(isPlaying: Bool = false) {
        self.isPlaying = isPlaying
    }
}
