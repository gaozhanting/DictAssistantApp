//
//  LanguageSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/24.
//

import SwiftUI

struct LanguageSettingsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            DoNameRecognitionToggle()
            DoPhraseDetectionToggle()
            Divider()
            
            UseAppleDictModePicker()
            UseEntryModePicker()
            Divider()
            
            DropTitleWordToggle()
            DropFirstTitleWordInTranslationToggle()
            JoinTranslationLinesToggle()
            ChineseCharacterConvertingPicker()
        }
        .padding()
        .frame(width: panelWidth)
    }
}

struct LanguageSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSettingsView()
    }
}
