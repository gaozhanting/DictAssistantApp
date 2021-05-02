//
//  ModelData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/30.
//

import Foundation
import Combine

final class ModelData: ObservableObject {
    @Published var words = [
        "favorite",
        "beauty",
        "POST",
        "information.",
        "customers,",
        "saying",
        "app.",
        "ications"
    ]
}
