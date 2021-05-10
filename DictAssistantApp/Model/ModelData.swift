//
//  ModelData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/30.
//

import Foundation
import Combine
import Cocoa
import DataBases

class ModelData: ObservableObject {
    @Published var words = [ // can't be empty; otherwise WordsView not displayed!!
        SingleClassifiedText(
            text: "favorite",
            existence: true,
            knowable: true,
            lookupable: true,
            translation: "最爱的"),
    ]
}
