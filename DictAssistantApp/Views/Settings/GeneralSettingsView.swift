//
//  GeneralSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/22.
//

import SwiftUI
import Preferences
import KeyboardShortcuts

//let settingPanelWidth: Double = 650.0
let panelWidth: Double = 500

struct GeneralSettingsView: View {
    var body: some View {
        VStack {
            KeyRecordingView()
            IsShowToastView()
        }
        .padding()
        .frame(width: panelWidth)
    }
}

private struct MultiToggles: View {
    @AppStorage(IsShowKnownKey) var isShowKnown: Bool = false
    @AppStorage(IsShowNotFoundKey) var isShowNotFound: Bool = false
    @AppStorage(IsShowKnownButWithOpacity0Key) var isShowKnownButWithOpacity0: Bool = false
    @AppStorage(IsConcealTranslationKey) var isConcealTranslation: Bool = false
    
    var body: some View {
        HStack {
            Text("Toggle Show Known")
            Spacer()
            Toggle("", isOn: $isShowKnown)
            KeyboardShortcuts.Recorder(for: .toggleShowKnown)
            MiniInfoView {
                Text("recommend: Option-2").font(.subheadline).padding()
            }
        }
        HStack {
            Text("Toggle Show Not-Found")
            Spacer()
            Toggle("", isOn: $isShowNotFound)
            KeyboardShortcuts.Recorder(for: .toggleShowNotFound)
            MiniInfoView {
                Text("recommend: Option-3").font(.subheadline).padding()
            }
        }
        
        Divider()
        
        HStack {
            Text("Toggle Conceal Known")
            Spacer()
            Toggle("", isOn: $isShowKnownButWithOpacity0)
            KeyboardShortcuts.Recorder(for: .toggleShowKnownButWithOpacity0)
            MiniInfoView {
                Text("recommend: Option-4").font(.subheadline).padding()
            }
        }
        HStack {
            Text("Toggle Conceal Translation")
            Spacer()
            Toggle("", isOn: $isConcealTranslation)
            KeyboardShortcuts.Recorder(for: .toggleConcealTranslation)
            MiniInfoView {
                Text("recommend: Option-5").font(.subheadline).padding()
            }
        }
    }
}

private struct KeyRecordingView: View {
    var g1: some View {
        Group {
            HStack {
                Text("Show Mini Known Panel")
                Spacer()
                KeyboardShortcuts.Recorder(for: .showMiniKnownPanel)
                MiniInfoView {
                    Text("recommend: Option-K").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Show Mini Phrase Panel")
                Spacer()
                KeyboardShortcuts.Recorder(for: .showMiniPhrasePanel)
                MiniInfoView {
                    Text("recommend: Option-P").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Show Mini Entry Panel")
                Spacer()
                KeyboardShortcuts.Recorder(for: .showMiniEntryPanel)
                MiniInfoView {
                    Text("recommend: Option-E").font(.subheadline).padding()
                }
            }
        }
    }
    
    var body: some View {
        Group {
            HStack {
                Text("Run Step Play")
                Spacer()
                KeyboardShortcuts.Recorder(for: .runStepPlay)
                MiniInfoView {
                    Text("recommend: Option-1").font(.subheadline).padding()
                }
            }
            
            MultiToggles()
            
            Divider()
            
            HStack {
                Text("Run Swift Play")
                Spacer()
                KeyboardShortcuts.Recorder(for: .runQuickPlay)
                MiniInfoView {
                    Text("recommend: Option-S").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Run Cheap Snapshot")
                Spacer()
                KeyboardShortcuts.Recorder(for: .runCheapSnapshot)
                MiniInfoView {
                    Text("recommend: Option-C").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Stop")
                Spacer()
                KeyboardShortcuts.Recorder(for: .stop)
                MiniInfoView {
                    Text("recommend: Option-X").font(.subheadline).padding()
                }
            }
            
            Divider()
            
            g1

            HStack {
                Text("Show Slots Tab")
                Spacer()
                KeyboardShortcuts.Recorder(for: .showSlotsTab)
                MiniInfoView {
                    Text("recommend: Option-Z").font(.subheadline).padding()
                }
            }
        }
        .toggleStyle(SwitchToggleStyle())
    }
}

private struct IsShowToastView: View {
    @AppStorage(IsShowToastKey) var isShowToast: Bool = true
    
    var body: some View {
        Toggle(isOn: $isShowToast, label: {
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
