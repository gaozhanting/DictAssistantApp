//
//  ContentMaxSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI

struct ContentMaxSettingsView: View {
    @AppStorage(PortraitMaxHeightKey) var portraitMaxHeight: Double = 100.0
    @AppStorage(LandscapeMaxWidthKey) var landscapeMaxWidth: Double = 160.0
    
    var body: some View {
        HStack {
            Text("Max height per entry:")
            TextField("", value: $portraitMaxHeight, formatter: tfDecimalFormatter).frame(width: tfWidth)
            
            Spacer()
            
            Text("Max width per entry:")
            TextField("", value: $landscapeMaxWidth, formatter: tfDecimalFormatter).frame(width: tfWidth)
        }
    }
}
