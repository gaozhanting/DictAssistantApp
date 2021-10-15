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
            Preferences.Section(title: NSLocalizedString("Show Phrases:", comment: "")) {
                ShowPhrasesToggle()
            }
            Preferences.Section(title: NSLocalizedString("Use Entry Mode:", comment: "")) {
                UseEntryModePicker()
            }
        }
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
    @AppStorage(UseEntryModeKey) private var useEntryMode: UseEntryMode = .asFirstPriority
    
    var binding: Binding<UseEntryMode> {
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
            Text("not use").tag(UseEntryMode.notUse)
            Text("as first priority").tag(UseEntryMode.asFirstPriority)
            Text("as last priority").tag(UseEntryMode.asLastPriority)
            Text("only").tag(UseEntryMode.only)
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
