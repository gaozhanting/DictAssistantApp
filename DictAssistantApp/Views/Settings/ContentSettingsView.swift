//
//  ContentSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI
import Preferences

struct ContentSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: NSLocalizedString("Content Style:", comment: "")) {
                ContentStyleSettingView()
            }
            Preferences.Section(title: NSLocalizedString("Content Display:", comment: "")) {
                DropTitleWordToggle()
                Divider().frame(width: 150)
                AddLineBreakBeforeTranslationToggle()
                AddSpaceBeforeTranslationToggle()
                DropFirstTitleWordInTranslationToggle()
                JoinTranslationLinesToggle()
            }
            Preferences.Section(title: NSLocalizedString("More:", comment: "")) {
                ChineseCharacterConvertingPicker()
            }
        }
        .overlay(
            QuestionMarkView {
                InfoView()
            },
            alignment: .bottomTrailing)
    }
}

private struct ContentStyleSettingView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: Int = ContentStyle.portrait.rawValue

    @AppStorage(PortraitCornerKey) private var portraitCorner: Int = PortraitCorner.topTrailing.rawValue
    @AppStorage(LandscapeStyleKey) private var landscapeStyle: Int = LandscapeStyle.normal.rawValue
    
    @State private var isShowTextField: Bool = false
    
    var binding: Binding<Bool> {
        Binding(
            get: { isShowTextField },
            set: { newValue in
                withAnimation {
                    isShowTextField = newValue
                }
            }
        )
    }
    
    // if not fold, this will effect the fontPanel which make change fontSize impossible, a weird issue.
    func fold() {
        isShowTextField = false
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("", selection: $contentStyle) {
                    Text("portrait").tag(ContentStyle.portrait.rawValue)
                    Text("landscape").tag(ContentStyle.landscape.rawValue)
                }
                .pickerStyle(MenuPickerStyle())
                .labelsHidden()
                .frame(width: 160)
                
                switch ContentStyle(rawValue: contentStyle)! {
                case .portrait:
                    Picker("from corner:", selection: $portraitCorner) {
                        Text("topTrailing").tag(PortraitCorner.topTrailing.rawValue)
                        Text("topLeading").tag(PortraitCorner.topLeading.rawValue)
                        Text("bottomLeading").tag(PortraitCorner.bottomLeading.rawValue)
                        Text("top").tag(PortraitCorner.top.rawValue)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                case .landscape:
                    Picker("style:", selection: $landscapeStyle) {
                        Text("normal").tag(LandscapeStyle.normal.rawValue)
                        Text("auto scrolling").tag(LandscapeStyle.autoScrolling.rawValue)
                        Text("centered").tag(LandscapeStyle.centered.rawValue)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                }
            }
            
            HStack {
                Toggle(isOn: binding, label: {
                    Text("More...")
                })
                .toggleStyle(SwitchToggleStyle())
                
                Spacer()
                
                if isShowTextField {
                    switch ContentStyle(rawValue: contentStyle)! {
                    case .portrait:
                        Text("max height for one word:")
                        PortraitMaxHeightTextField(fold: fold)
                            .frame(width: 46)
                    case .landscape:
                        Text("max width for one word:")
                        LandscapeMaxWidthTextField(fold: fold)
                            .frame(width: 46)
                    }
                }
            }
            .frame(width: 370)
        }
    }
}

private struct PortraitMaxHeightTextField: View {
    let fold: () -> Void
    
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 100.0
    
    @State var showingAlert: Bool = false

    var binding: Binding<String> {
        Binding(
            get: { String(portraitMaxHeight) },
            set: { newValue in
                guard let newValue = Double(newValue) else {
                    showingAlert = true
                    return
                }
                
                portraitMaxHeight = newValue
            }
        )
    }
    
    var body: some View {
        TextField("", text: binding, onCommit: fold)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Invalid value"), message: Text("Value must be a number"))
            }
    }
}

private struct LandscapeMaxWidthTextField: View {
    let fold: () -> Void
    
    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 160.0
    
    @State var showingAlert: Bool = false
    
    var binding: Binding<String> {
        Binding(
            get: { String(landscapeMaxWidth) },
            set: { newValue in
                guard let newValue = Double(newValue) else {
                    showingAlert = true
                    return
                }
                
                landscapeMaxWidth = newValue
            }
        )
    }
    
    var body: some View {
        TextField("", text: binding, onCommit: fold)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Invalid value"), message: Text("Value must be a number"))
            }
    }
}

private struct InfoView: View {
    var body: some View {
        Text("If the content is empty when you did run playing, what you can do?\n1. Check if there indeed has some English text in cropper area \n2. Try to turn down the Minimum Text Height \n3. Try to use Text Recognition Level accurate level \n4. Check if the words in the cropper screen are not all in your known words list \n5. Make sure the Use Entry Mode is not selected to only when you have no custom entries, which will ignore builtIn dictionary and Apple Dictionary \n6. Make sure you have already built a dictionary successfully, or make sure you did selected a valid dictionary in your Apple Dictionary Preferences if you select to use Apple Dictionary \n7. Replay (when sometimes you switch screens) \n\nHere are some tips for you:\n1. When you changed the Apple Dictionary Preferences, you need to restart this App(not restart the Apple Dictionary App) in order to take effect.\n2. In the content, you can right click (or command click) the word, and there are commands for quick add/remove to known. Remove From Known will only be available when you toggle Show Current Known Words on.\n3. Some hotkeys: Option Click the word will add or remove to known; Command Click the word will speak the word using system speech voice; Shift Click the word will open the Apple Dictionary App of the word.")
            .font(.callout)
            .padding()
            .frame(width: 520)
    }
}

private struct DropTitleWordToggle: View {
    @AppStorage(IsDropTitleWordKey) private var isDropTitleWord: Bool = false

    var body: some View {
        Toggle(isOn: $isDropTitleWord, label: {
            Text("Drop title word")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you don't want to show the title word. Some dictionary make the title word not the first word in translation, but behind, for example: スーパー大辞林 / Super Daijirin Japanese Dictionary. And in some dictionary, title word in translation is broken up into syllables, this case, you could select this while deselect Drop first word in translation, that will be better.")
    }
}

private struct AddLineBreakBeforeTranslationToggle: View {
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    
    var body: some View {
        Toggle(isOn: $isAddLineBreak, label: {
            Text("Add line break ahead of translation")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

private struct AddSpaceBeforeTranslationToggle: View {
    @AppStorage(IsAddSpaceKey) private var isAddSpace: Bool = false
    
    var body: some View {
        Toggle(isOn: $isAddSpace, label: {
            Text("Add space ahead of translation")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

private struct DropFirstTitleWordInTranslationToggle: View {
    @AppStorage(IsDropFirstTitleWordInTranslationKey) private var isDropFirstTitleWordInTranslation: Bool = true
    
    var body: some View {
        Toggle(isOn: $isDropFirstTitleWordInTranslation, label: {
            Text("Drop first title word in translation")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want to drop the first word, normally the current title word from translation text. Notice, some dictionary has not set the title word at the beginning of the translation; for example: スーパー大辞林 / Super Daijirin Japanese Dictionary; you could unselect it because the count is not correct.")
    }
}

private struct JoinTranslationLinesToggle: View {
    @AppStorage(IsJoinTranslationLinesKey) private var isJoinTranslationLines: Bool = true
    
    var body: some View {
        Toggle(isOn: $isJoinTranslationLines, label: {
            Text("Join translation lines")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

private struct ChineseCharacterConvertingPicker: View {
    @State private var showPicker: Bool = false
    
    var binding: Binding<Bool> {
        Binding(
            get: { showPicker },
            set: { newValue in
                withAnimation {
                    showPicker = newValue
                }
            }
        )
    }
    
    @AppStorage(ChineseCharacterConvertModeKey) private var chineseCharacterConvertMode: Int = ChineseCharacterConvertMode.notConvert.rawValue

    var body: some View {
        HStack {
            Toggle(isOn: binding, label: {
                Text("")
            })
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle())
            
            if showPicker {
                Picker("Chinese Character Convert:", selection: $chineseCharacterConvertMode) {
                    Text("not convert").tag(ChineseCharacterConvertMode.notConvert.rawValue)
                    Text("convert to traditional").tag(ChineseCharacterConvertMode.convertToTraditional.rawValue)
                    Text("convert to simplified").tag(ChineseCharacterConvertMode.convertToSimplified.rawValue)
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: 360)
            }
        }
    }
}

struct ContentSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentSettingsView()
            
            InfoView()
        }
//        .environment(\.locale, .init(identifier: "zh-Hans"))
        .environment(\.locale, .init(identifier: "en"))
    }
}
