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
                KnownWordsView()
            }
            .tabItem {
                Text("Known Words")
            }
            
            VStack {
                GroupBox {
                    CustomDictView()
                }
                UseCustomDictModePicker()
            }
            .tabItem {
                Text("Custom Dict")
            }
            
            Text("Third Party Dict")
                .tabItem {
                    Text("Third Party Dict")
                }
        }
        .environment(\.managedObjectContext, persistentContainer.viewContext)
        .padding(.top, 10)
        .frame(width: CGFloat(settingPanelWidth))
        .frame(minHeight: 600)
    }
}

fileprivate struct UseCustomDictModePicker: View {
    @AppStorage(UseCustomDictModeKey) private var useCustomDictMode: UseCustomDictMode = .notUse
    
    var binding: Binding<UseCustomDictMode> {
        Binding(
            get: { useCustomDictMode },
            set: { newValue in
                useCustomDictMode = newValue
                cachedDict = [:]
                trCallBack()
            }
        )
    }
    
    var body: some View {
        Picker("Use Custom Dict Mode:", selection: binding) {
            Text("not use").tag(UseCustomDictMode.notUse)
            Text("as first priority").tag(UseCustomDictMode.asFirstPriority)
            Text("as last priority").tag(UseCustomDictMode.asLastPriority)
            Text("only").tag(UseCustomDictMode.only)
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
