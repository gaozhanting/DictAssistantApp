//
//  GeneralSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/22.
//

import SwiftUI
import Preferences
import KeyboardShortcuts

let settingPanelWidth: Double = 650.0

struct GeneralSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: NSLocalizedString("Global Keyboard Shortcuts:", comment: "")) {
                KeyRecordingView()
                    .frame(maxWidth: .infinity)
            }
            Preferences.Section(title: NSLocalizedString("Toast:", comment: "")) {
                ShowToastToggle()
            }
        }
    }
}

private struct KeyRecordingView: View {
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    @AppStorage(IsShowCurrentKnownButWithOpacity0Key) private var isShowCurrentKnownButWithOpacity0: Bool = false
    @AppStorage(IsConcealTranslationKey) private var isConcealTranslation: Bool = false
    @AppStorage(IsShowCurrentNotFoundWordsKey) private var isShowCurrentNotFoundWords: Bool = false
    
    var body: some View {
        Group {
            HStack {
                Text("Run Step Play")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleStepPlay)
                MiniInfoView {
                    Text("recommend: Option-1").font(.subheadline).padding()
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Toggle Show Current Known Words")
                Spacer()
                Toggle("", isOn: $isShowCurrentKnown).labelsHidden()
                KeyboardShortcuts.Recorder(for: .toggleShowCurrentKnown)
                MiniInfoView {
                    Text("recommend: Option-2").font(.subheadline).padding()
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Toggle Show Current Not-Found Words")
                Spacer()
                Toggle("", isOn: $isShowCurrentNotFoundWords).labelsHidden()
                KeyboardShortcuts.Recorder(for: .toggleShowCurrentNotFoundWords)
                MiniInfoView {
                    Text("recommend: Option-3").font(.subheadline).padding()
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Toggle Conceal Current Known Words")
                Spacer()
                Toggle("", isOn: $isShowCurrentKnownButWithOpacity0).labelsHidden()
                KeyboardShortcuts.Recorder(for: .toggleShowCurrentKnownButWithOpacity0)
                MiniInfoView {
                    Text("recommend: Option-4").font(.subheadline).padding()
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Toggle Conceal Translation")
                Spacer()
                Toggle("", isOn: $isConcealTranslation).labelsHidden()
                KeyboardShortcuts.Recorder(for: .toggleConcealTranslation)
                MiniInfoView {
                    Text("recommend: Option-5").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Run Swift Play")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleQuickPlay)
                MiniInfoView {
                    Text("recommend: Option-S").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Show Phrase Insert Panel")
                Spacer()
                KeyboardShortcuts.Recorder(for: .showPhraseInsertPanel)
                MiniInfoView {
                    Text("recommend: Option-P").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Show Entry Upsert Panel")
                Spacer()
                KeyboardShortcuts.Recorder(for: .showUpsertEntryPanel)
                MiniInfoView {
                    Text("recommend: Option-E").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Show Preferences Panel")
                Spacer()
                KeyboardShortcuts.Recorder(for: .showPreferencesPanel)
                MiniInfoView {
                    Text("recommend: Option-C").font(.subheadline).padding()
                }
            }
        }
        .toggleStyle(SwitchToggleStyle())
    }
}

private struct ShowToastToggle: View {
    @AppStorage(ShowToastToggleKey) private var showToast: Bool = true
    
    var body: some View {
        Toggle(isOn: $showToast, label: {
            Text("Show Toast")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

struct GeneralSettingView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
            .environment(\.locale, .init(identifier: "en"))
    }
}
