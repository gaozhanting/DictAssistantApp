//
//  EnglishSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI

struct EnglishSettingsView: View {
    var body: some View {
        TabView {
            Text("Third Party Dict")
                .tabItem {
                    Text("Third Party Dict")
                }
            
            GroupBox {
                PhrasesView()
            }
            .tabItem {
                Text("Phrases")
            }
            
            GroupBox {
                NoiseView()
            }
            .tabItem {
                Text("Noises")
            }
            
            GroupBox {
                KnownView()
            }
            .tabItem {
                Text("Known")
            }
            
            VStack {
                GroupBox {
                    EntryView()
                }
                UseEntryModePicker()
            }
            .tabItem {
                Text("Entries")
            }
        }
        .environment(\.managedObjectContext, persistentContainer.viewContext)
        .padding(.top, 10)
        .frame(width: CGFloat(settingPanelWidth))
        .frame(minHeight: 600)
    }
}

fileprivate struct UseEntryModePicker: View {
    @AppStorage(UseEntryModeKey) private var useEntryMode: UseEntryMode = .notUse
    
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
        Picker("Use Custom Dict Mode:", selection: binding) {
            Text("not use").tag(UseEntryMode.notUse)
            Text("as first priority").tag(UseEntryMode.asFirstPriority)
            Text("as last priority").tag(UseEntryMode.asLastPriority)
            Text("only").tag(UseEntryMode.only)
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 360)
    }
}

struct DictSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        EnglishSettingsView()
    }
}
