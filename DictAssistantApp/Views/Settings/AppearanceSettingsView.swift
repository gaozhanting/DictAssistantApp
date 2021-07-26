//
//  AppearanceSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import SwiftUI
import Preferences

struct AppearanceSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: "Cropper Style:") {
                CropperStyleSettingView()
            }
            Preferences.Section(title: "Content Style:") {
                ContentStyleSettingView()
            }
//            Preferences.Section(title: "Word Color:") {
//                WordColorSettingView()
//            }
            Preferences.Section(title: "Words Display:") {
                ContentWindowShadowToggle()
                WithAnimationToggle()
                ShowCurrentKnownWordsToggle()
                ShowPhrasesToggle()
                AddLineBreakToggle()
            }
        }
    }
}

enum CropperStyle: Int {
    case closed = 0
    case rectangle = 1
}

fileprivate struct CropperStyleSettingView: View {
    @AppStorage(CropperStyleKey) private var cropperStyle: CropperStyle = .closed
    
    var bd: Binding<CropperStyle> {
        Binding.init {
            cropperStyle
        } set: { newValue in
            cropperStyle = newValue
            toggleCropperView()
        }
    }
    
    var body: some View {
        Picker("", selection: bd) {
            Text("closed").tag(CropperStyle.closed)
            Text("rectangle").tag(CropperStyle.rectangle)
        }
        .pickerStyle(MenuPickerStyle())
        .labelsHidden()
        .frame(width: 160)
    }
}

enum ContentStyle: Int {
    case portrait = 0
    case landscape = 1
}

fileprivate struct ContentStyleSettingView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portrait
    
    var body: some View {
        Picker("", selection: $contentStyle) {
            Text("portrait").tag(ContentStyle.portrait)
            Text("landscape").tag(ContentStyle.landscape)
        }
        .pickerStyle(MenuPickerStyle())
        .labelsHidden()
        .frame(width: 160)
    }
}

//fileprivate struct WordColorSettingView: View {
//    @State private var color = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
//
//    var body: some View {
//        ColorPicker("", selection: $color)
//            .labelsHidden()
//    }
//}

fileprivate struct ShowCurrentKnownWordsToggle: View {
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    
    var body: some View {
        Toggle(isOn: $isShowCurrentKnown, label: {
            Text("Show current known words")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want to display current known words.")
    }
}

fileprivate struct ShowPhrasesToggle: View {
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true
    
    var body: some View {
        Toggle(isOn: $isShowPhrase, label: {
            Text("Show phrases")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want display all phrase words.")
    }
}

fileprivate struct AddLineBreakToggle: View {
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreakKey: Bool = true
    
    var body: some View {
        Toggle(isOn: $isAddLineBreakKey, label: {
            Text("Add line break")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want add a line break between the word and the translation of the word.")
    }
}

fileprivate struct ContentWindowShadowToggle: View {
    @AppStorage(IsShowWindowShadowKey) private var isShowWindowShadow = false
    
    var bd: Binding<Bool> {
        Binding.init {
            isShowWindowShadow
        } set: { newValue in
            isShowWindowShadow = newValue
            toggleContentShadow()
        }
    }
    
    var body: some View {
        Toggle(isOn: bd, label: {
            Text("Show Content Window Shadow")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you prefer window shadow, notice it may mess up. You should replay to take effect of it.")
    }
}

fileprivate struct WithAnimationToggle: View {
    @AppStorage(IsWithAnimationKey) private var isWithAnimation: Bool = true
        
    var body: some View {
        Toggle(isOn: $isWithAnimation, label: {
            Text("Show animation")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you prefer animation for displaying words.")
    }
}

struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingsView()
            .frame(width: 650, height: 500)
    }
}
