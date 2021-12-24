//
//  DictionarySettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI
import Preferences
import CoreML

struct UseAppleDictModePicker: View {
    @AppStorage(UseAppleDictModeKey) private var useAppleDictMode: Int = UseAppleDictMode.afterBuiltIn.rawValue
    
    var body: some View {
        HStack {
            Text("Use Apple Dict Mode")
            Spacer()
            Picker("", selection: $useAppleDictMode) {
                Text("not use").tag(UseAppleDictMode.notUse.rawValue)
                Text("after built in").tag(UseAppleDictMode.afterBuiltIn.rawValue)
                Text("before built in").tag(UseAppleDictMode.beforeBuiltIn.rawValue)
                Text("only").tag(UseAppleDictMode.only.rawValue)
            }
            .frame(width: 200)
            .pickerStyle(MenuPickerStyle())
            
            MiniInfoView {
                UseAppleDictModeInfoView()
            }
        }
    }
}

private struct UseAppleDictModeInfoView: View {
    var body: some View {
        Text("Builtin Dictionary and Apple Dictionary makes up our local dictionary database.")
            .infoStyle()
    }
}

struct UseEntryModePicker: View {
    @AppStorage(UseEntryModeKey) private var useEntryMode: Int = UseEntryMode.asFirstPriority.rawValue
    
    var body: some View {
        HStack {
            Text("Use Custom Entries Mode")
            Spacer()
            Picker("", selection: $useEntryMode) {
                Text("not use").tag(UseEntryMode.notUse.rawValue)
                Text("as first priority").tag(UseEntryMode.asFirstPriority.rawValue)
                Text("as last priority").tag(UseEntryMode.asLastPriority.rawValue)
                Text("only").tag(UseEntryMode.only.rawValue)
            }
            .frame(width: 200)
            .pickerStyle(MenuPickerStyle())
            
            MiniInfoView {
                UseEntryModeInfoView()
            }
        }
    }
}

private struct UseEntryModeInfoView: View {
    var body: some View {
        Text("Note, if you don't select open of Lemma Search Level, and at the same time the lemma of your custom entry word can't be found (in apple or database), then it still can't be shown. Your entries is just another dictionary.")
            .infoStyle()
    }
}

struct DictSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UseAppleDictModeInfoView()
            UseEntryModeInfoView()
        }
//        .environment(\.locale, .init(identifier: "zh-Hans"))
        .environment(\.locale, .init(identifier: "en"))
    }
}
