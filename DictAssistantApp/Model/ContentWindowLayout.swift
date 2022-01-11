//
//  ContentWindowLayout.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2022/1/11.
//

import Foundation

// content view layout react to content window frame
class ContentWindowLayout: ObservableObject {
    @Published var layout: ContentLayout
    
    init() {
        self.layout = calculateLayout(from: contentWindow.frame)
    }
}

let contentWindowLayout = ContentWindowLayout()

func calculateLayout(from contentWindowFrame: NSRect) -> ContentLayout {
    contentWindowFrame.height > contentWindowFrame.width ?
        .portrait :
        .landscape
}
