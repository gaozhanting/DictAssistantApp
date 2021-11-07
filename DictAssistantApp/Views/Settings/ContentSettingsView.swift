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
            Preferences.Section(title: NSLocalizedString("Content Display:", comment: "")) {
                DropTitleWordToggle()
                Divider().frame(width: 150)
                AddLineBreakBeforeTranslationToggle()
                AddSpaceBeforeTranslationToggle()
                DropFirstTitleWordInTranslationToggle()
                JoinTranslationLinesToggle()
            }
            Preferences.Section(title: NSLocalizedString("Title Word:", comment: "")) {
                TitleWordPicker()
            }
            Preferences.Section(title: NSLocalizedString("More:", comment: "")) {
                ChineseCharacterConvertingPicker()
            }
        }
        .overlay(
            Button(action: { isShowingPopover = true }, label: {
                Image(systemName: "questionmark").font(.body)
            })
                .clipShape(Circle())
                .padding()
                .shadow(radius: 1)
                .popover(isPresented: $isShowingPopover, arrowEdge: .leading, content: {
                    InfoView()
                })
            ,
            alignment: .bottomTrailing)
    }
    
    @State private var isShowingPopover: Bool = false
}

private struct InfoView: View {
    var body: some View {
        Text("If the content is empty when you did run playing, what you can do?\n1. Check if there indeed has some English text in cropper area \n2. Try to turn down the `Minimum Text Height` \n3. Try to use `Text Recognition Level` accurate level \n4. Check if the words in the cropper screen are not all in your known words list \n5. Make sure the `Use Entry Mode` is not `only` which will ignore Apple Dictionary \n6. Make sure you did selected a valid dictionary in your Apple Dictionary Preferences \n7. Replay (when sometimes you switch screens) \n\nHere are some tips for you:\n1. When you changed the Apple Dictionary Preferences, you need to restart this App(not restart the Apple Dictionary App) in order to take effect, in order to conform the reordered dictionaries you adjusted.\n2. In the content, you can right click (or command click) the word, and there are commands in contextual menu buttons for quick add/remove to known, add/remove noises. `Remove From Known` will only be available when you toggle `Show Current Known Words` on; and whether display `Add To Noises` or `Remove From Noises` are based on if the word is in noises or not.\n3. Some hotkeys: Option Click the word will add or remove to known; Command Click the word will speak the word using system speech voice; Shift Click the word will open the Dictionary App of the word.")
            .padding()
            .frame(width: 570, height: 380)
    }
}

fileprivate struct DropTitleWordToggle: View {
    @AppStorage(IsDropTitleWordKey) private var isDropTitleWord: Bool = false

    var body: some View {
        Toggle(isOn: $isDropTitleWord, label: {
            Text("Drop title word")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you don't want to show the title word. Some dictionary make the title word not the first word in translation, but behind, for example: スーパー大辞林 / Super Daijirin Japanese Dictionary. And in some dictionary, title word in translation is broken up into syllables, this case, you could select this while deselect `Drop first word in translation`, that will be better.")
    }
}

fileprivate struct AddLineBreakBeforeTranslationToggle: View {
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    
    var body: some View {
        Toggle(isOn: $isAddLineBreak, label: {
            Text("Add line break ahead of translation")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

fileprivate struct AddSpaceBeforeTranslationToggle: View {
    @AppStorage(IsAddSpaceKey) private var isAddSpace: Bool = false
    
    var body: some View {
        Toggle(isOn: $isAddSpace, label: {
            Text("Add space ahead of translation")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

fileprivate struct DropFirstTitleWordInTranslationToggle: View {
    @AppStorage(IsDropFirstTitleWordInTranslationKey) private var isDropFirstTitleWordInTranslation: Bool = true
    
    var body: some View {
        Toggle(isOn: $isDropFirstTitleWordInTranslation, label: {
            Text("Drop first title word in translation")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want to drop the first word, normally the current title word from translation text. Notice, some dictionary has not set the title word at the beginning of the translation; for example: スーパー大辞林 / Super Daijirin Japanese Dictionary; you could unselect it because the count is not correct.")
    }
}

fileprivate struct JoinTranslationLinesToggle: View {
    @AppStorage(IsJoinTranslationLinesKey) private var isJoinTranslationLines: Bool = true
    
    var body: some View {
        Toggle(isOn: $isJoinTranslationLines, label: {
            Text("Join translation lines")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

private struct TitleWordPicker: View {
    @AppStorage(TitleWordKey) private var titleWord: Int = TitleWord.primitive.rawValue
    
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
            Text("primitive").tag(TitleWord.primitive.rawValue)
            Text("lemma").tag(TitleWord.lemma.rawValue)
        }
        .labelsHidden()
        .pickerStyle(MenuPickerStyle())
        .frame(width: 150)
    }
}

fileprivate struct ChineseCharacterConvertingPicker: View {
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
//                .environment(\.locale, .init(identifier: "zh-Hans"))
        }
    }
}
