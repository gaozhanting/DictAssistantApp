//
//  EnglishSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI
import Preferences

struct EnglishSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: NSLocalizedString("Title Word:", comment: "")) {
                TitleWordPicker()
            }
            Preferences.Section(title: NSLocalizedString("Phrases:", comment: "")) {
                ShowPhrasesToggle()
            }
            Preferences.Section(title: NSLocalizedString("Use Entry Mode:", comment: "")) {
                UseEntryModePicker()
            }
        }
    }
}

private struct TitleWordPicker: View {
    @AppStorage(TitleWordKey) private var titleWord: Int = TitleWord.lemma.rawValue
    
    var binding: Binding<Int> {
        Binding(
            get: { titleWord },
            set: { newValue in
                titleWord = newValue
                trCallBack()
            }
        )
    }
    
    var body: some View {
        Picker("", selection: binding) {
            Text("lemma").tag(TitleWord.lemma.rawValue)
            Text("primitive").tag(TitleWord.primitive.rawValue)
        }
        .labelsHidden()
        .pickerStyle(MenuPickerStyle())
        .frame(width: 150)
    }
}

private struct ShowPhrasesToggle: View {
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true
    
    var body: some View {
        Toggle(isOn: $isShowPhrase, label: {
            Text("Show Phrases")
        })
            .toggleStyle(CheckboxToggleStyle())
            .help("Select it when you want display all phrase words.")
    }
}

private struct UseEntryModePicker: View {
    @AppStorage(UseEntryModeKey) private var useEntryMode: Int = UseEntryMode.asFirstPriority.rawValue
    
    var binding: Binding<Int> {
        Binding(
            get: { useEntryMode },
            set: { newValue in
                useEntryMode = newValue
                cachedDict = [:]
                trCallBack()
            }
        )
    }
    
    var body: some View {
        Picker("", selection: binding) {
            Text("not use").tag(UseEntryMode.notUse.rawValue)
            Text("as first priority").tag(UseEntryMode.asFirstPriority.rawValue)
            Text("as last priority").tag(UseEntryMode.asLastPriority.rawValue)
            Text("only").tag(UseEntryMode.only.rawValue)
        }
        .labelsHidden()
        .pickerStyle(MenuPickerStyle())
        .frame(width: 200)
        .help("Choose the way you want to use for your custom entries.")
    }
}

struct DictSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        EnglishSettingsView()
    }
}
