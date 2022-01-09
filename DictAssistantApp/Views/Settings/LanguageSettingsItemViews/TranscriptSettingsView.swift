//
//  TranscriptSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/17.
//

import SwiftUI
import Preferences

struct ChineseCharacterConvertingPicker: View {
    @AppStorage(ChineseCharacterConvertModeKey) var chineseCharacterConvertMode: Int = ChineseCharacterConvertMode.notConvert.rawValue

    var body: some View {
        Picker("Chinese Character Convert:", selection: $chineseCharacterConvertMode) {
            Text("not convert").tag(ChineseCharacterConvertMode.notConvert.rawValue)
            Text("convert to traditional").tag(ChineseCharacterConvertMode.convertToTraditional.rawValue)
            Text("convert to simplified").tag(ChineseCharacterConvertMode.convertToSimplified.rawValue)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 350)
    }
}
