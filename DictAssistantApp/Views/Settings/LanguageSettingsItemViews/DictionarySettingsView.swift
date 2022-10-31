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
    @AppStorage(UseAppleDictModeKey) var useAppleDictMode: Int = UseAppleDictMode.afterBuiltIn.rawValue
    
    var body: some View {
        HStack {
            Text("Use apple dict mode")
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
        Text("Builtin dictionary and Apple dictionary makes up our local dictionary database.")
            .infoStyle()
    }
}

struct UseEntryModePicker: View {
    @AppStorage(UseEntryModeKey) var useEntryMode: Int = UseEntryMode.asFirstPriority.rawValue
    
    var body: some View {
        HStack {
            Text("Use custom entries mode")
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
        Text("Note, if you unselected Is open lemma Option in Scene Tab, and at the same time the lemma of your custom entry word can't be found, then it still can't be shown. \nYour entries is just another dictionary.")
            .infoStyle()
    }
}

struct DictSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UseAppleDictModeInfoView()
            UseEntryModeInfoView()
        }
    }
}
