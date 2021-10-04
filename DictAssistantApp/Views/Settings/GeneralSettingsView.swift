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
                KeyRecordingView(onboarding: false)
                    .frame(maxWidth: .infinity)
            }
            Preferences.Section(title: NSLocalizedString("Toast:", comment: "")) {
                ShowToastToggle()
            }
        }
    }
}

struct MiniInfoView<Content: View>: View {
    let arrowEdge: Edge
    let content: Content
    
    init(arrowEdge: Edge = .top, @ViewBuilder content: () -> Content) {
        self.arrowEdge = arrowEdge
        self.content = content()
    }
    
    @State private var isShowingPopover = false
    
    var body: some View {
        Button(action: { isShowingPopover = true }, label: {
            Image(systemName: "info.circle")
                .font(.footnote)
        })
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $isShowingPopover, arrowEdge: arrowEdge) {
            content
        }
    }
}

struct KeyRecordingView: View {
    let onboarding: Bool
    
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    @AppStorage(IsShowCurrentKnownButWithOpacity0Key) private var isShowCurrentKnownButWithOpacity0: Bool = false
    @AppStorage(IsConcealTranslationKey) private var isConcealTranslation: Bool = false
    @AppStorage(IsShowCurrentNotFoundWordsKey) private var isShowCurrentNotFoundWords: Bool = false

    var body: some View {
        Group {
            HStack {
                Text("Run Flow Step:")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleFlowStep)
                MiniInfoView {
                    Text("recommend: Option-1").padding()
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Toggle Show Current Known Words:")
                Spacer()
                Toggle("", isOn: $isShowCurrentKnown).labelsHidden()
                KeyboardShortcuts.Recorder(for: .toggleShowCurrentKnown)
                MiniInfoView {
                    Text("recommend: Option-2").padding()
                }
            }
            if !onboarding {
                HStack(alignment: .firstTextBaseline) {
                    Text("Toggle Conceal Current Known Words:")
                    Spacer()
                    Toggle("", isOn: $isShowCurrentKnownButWithOpacity0).labelsHidden()
                    KeyboardShortcuts.Recorder(for: .toggleShowCurrentKnownButWithOpacity0)
                    MiniInfoView {
                        Text("recommend: Option-3").padding()
                    }
                }
                HStack(alignment: .firstTextBaseline) {
                    Text("Toggle Conceal Translation:")
                    Spacer()
                    Toggle("", isOn: $isConcealTranslation).labelsHidden()
                    KeyboardShortcuts.Recorder(for: .toggleConcealTranslation)
                    MiniInfoView {
                        Text("recommend: Option-4").padding()
                    }
                }
                HStack(alignment: .firstTextBaseline) {
                    Text("Toggle Show Current Not-Found Words:")
                    Spacer()
                    Toggle("", isOn: $isShowCurrentNotFoundWords).labelsHidden()
                    KeyboardShortcuts.Recorder(for: .toggleShowCurrentNotFoundWords)
                    MiniInfoView {
                        Text("recommend: Option-5").padding()
                    }
                }
            }
        }
        .toggleStyle(SwitchToggleStyle())
    }
}

fileprivate struct ShowToastToggle: View {
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
