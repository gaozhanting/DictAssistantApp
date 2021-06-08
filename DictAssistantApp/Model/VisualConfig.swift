//
//  VisualConfig.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/8.
//

import Foundation

enum DisplayMode: String, CaseIterable, Identifiable {
    case landscape // for reading subtitle when watching movie
    case portrait // for reading articles
    
    var id: String { self.rawValue }
}

class VisualConfig: ObservableObject {
    @Published var displayMode: DisplayMode
    
    init(displayMode: DisplayMode = .landscape) {
        if let displayMode = UserDefaults.standard.string(forKey: "visualConfig.displayMode") {
            self.displayMode = DisplayMode(rawValue: displayMode)!
        } else {
            self.displayMode = displayMode
        }
    }
}
