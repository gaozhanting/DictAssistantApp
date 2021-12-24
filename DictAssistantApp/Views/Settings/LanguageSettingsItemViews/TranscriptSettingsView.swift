//
//  TranscriptSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/17.
//

import SwiftUI
import Preferences

struct DropTitleWordToggle: View {
    @AppStorage(IsDropTitleWordKey) private var isDropTitleWord: Bool = false

    var body: some View {
        Toggle(isOn: $isDropTitleWord, label: {
            Text("Drop title word")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you don't want to show the title word. Some dictionary make the title word not the first word in translation, but behind, for example: スーパー大辞林 / Super Daijirin Japanese Dictionary. And in some dictionary, title word in translation is broken up into syllables, this case, you could select this while deselect Drop first word in translation, that will be better.")
    }
}

struct AddLineBreakBeforeTranslationToggle: View {
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    
    var body: some View {
        Toggle(isOn: $isAddLineBreak, label: {
            Text("Add line break ahead of translation")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

struct AddSpaceBeforeTranslationToggle: View {
    @AppStorage(IsAddSpaceKey) private var isAddSpace: Bool = false
    
    var body: some View {
        Toggle(isOn: $isAddSpace, label: {
            Text("Add space ahead of translation")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

struct DropFirstTitleWordInTranslationToggle: View {
    @AppStorage(IsDropFirstTitleWordInTranslationKey) private var isDropFirstTitleWordInTranslation: Bool = true
    
    var body: some View {
        Toggle(isOn: $isDropFirstTitleWordInTranslation, label: {
            Text("Drop first title word in translation")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want to drop the first word, normally the current title word from translation text. Notice, some dictionary has not set the title word at the beginning of the translation; for example: スーパー大辞林 / Super Daijirin Japanese Dictionary; you could unselect it because the count is not correct.")
    }
}

struct JoinTranslationLinesToggle: View {
    @AppStorage(IsJoinTranslationLinesKey) private var isJoinTranslationLines: Bool = true
    
    var body: some View {
        Toggle(isOn: $isJoinTranslationLines, label: {
            Text("Join translation lines")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

struct ChineseCharacterConvertingPicker: View {
    @AppStorage(ChineseCharacterConvertModeKey) private var chineseCharacterConvertMode: Int = ChineseCharacterConvertMode.notConvert.rawValue

    var body: some View {
        Picker("Chinese Character Convert:", selection: $chineseCharacterConvertMode) {
            Text("not convert").tag(ChineseCharacterConvertMode.notConvert.rawValue)
            Text("convert to traditional").tag(ChineseCharacterConvertMode.convertToTraditional.rawValue)
            Text("convert to simplified").tag(ChineseCharacterConvertMode.convertToSimplified.rawValue)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 300)
    }
}

//struct TranscriptSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TranscriptSettingsView()
//    }
//}
