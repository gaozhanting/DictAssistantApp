//
//  ShortcutsSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/22.
//

import SwiftUI
import Preferences
import KeyboardShortcuts

//let settingPanelWidth: Double = 650.0
let panelWidth: Double = 500

struct ShortcutsSettingsView: View {
    var body: some View {
        KeyRecordingView()
            .padding()
            .frame(width: panelWidth)
    }
}

private struct KeyRecordingView: View {
    @AppStorage(IsShowContentFrameKey) var isShowContentFrame: Bool = false
    @AppStorage(IsAddLineBreakKey) var isAddLineBreak: Bool = true
    var g1: some View {
        Group {
            HStack {
                Text("Run step play")
                Spacer()
                KeyboardShortcuts.Recorder(for: .runStepPlay)
                MiniInfoView {
                    Text("recommend: Option-1").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Toggle content frame")
                Spacer()
                Toggle("", isOn: $isShowContentFrame)
                KeyboardShortcuts.Recorder(for: .toggleContentFrame)
                MiniInfoView {
                    Text("recommend: Option-F").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Switch content layout")
                Spacer()
                KeyboardShortcuts.Recorder(for: .switchAnchor)
                MiniInfoView {
                    Text("recommend: Option-L\nSwitch content layout between top, topTrailing, topLeading and bottom when portrait, or leading and center when landscape.")
                        .infoStyle()
                }
            }
            HStack {
                Text("Toggle add line break")
                Spacer()
                Toggle("", isOn: $isAddLineBreak)
                KeyboardShortcuts.Recorder(for: .toggleAddLineBreak)
                MiniInfoView {
                    Text("recommend: Option-B").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Toggle mini known panel")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleMiniKnownPanel)
                MiniInfoView {
                    Text("recommend: Option-K").font(.subheadline).padding()
                }
            }
            Divider()
        }
    }
    
    @AppStorage(IsShowKnownKey) var isShowKnown: Bool = false
    @AppStorage(IsShowNotFoundKey) var isShowNotFound: Bool = false
    @AppStorage(IsShowKnownButWithOpacity0Key) var isShowKnownButWithOpacity0: Bool = false
    @AppStorage(IsConcealTranslationKey) var isConcealTranslation: Bool = false
    var g2: some View {
        Group {

            HStack {
                Text("Toggle show known")
                Spacer()
                Toggle("", isOn: $isShowKnown)
                KeyboardShortcuts.Recorder(for: .toggleShowKnown)
                MiniInfoView {
                    Text("recommend: Option-2").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Toggle show not-found")
                Spacer()
                Toggle("", isOn: $isShowNotFound)
                KeyboardShortcuts.Recorder(for: .toggleShowNotFound)
                MiniInfoView {
                    Text("recommend: Option-3").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Toggle conceal known")
                Spacer()
                Toggle("", isOn: $isShowKnownButWithOpacity0)
                KeyboardShortcuts.Recorder(for: .toggleShowKnownButWithOpacity0)
                MiniInfoView {
                    Text("recommend: Option-4").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Toggle conceal translation")
                Spacer()
                Toggle("", isOn: $isConcealTranslation)
                KeyboardShortcuts.Recorder(for: .toggleConcealTranslation)
                MiniInfoView {
                    Text("recommend: Option-5").font(.subheadline).padding()
                }
            }
            Divider()
        }
    }

    
    var g3: some View {
        Group {
            HStack {
                Text("Run swift play")
                Spacer()
                KeyboardShortcuts.Recorder(for: .runQuickPlay)
                MiniInfoView {
                    Text("recommend: Option-S").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Run cheap snapshot")
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
        }
    }
        
    var g4: some View {
        Group {
            HStack {
                Text("Toggle mini phrase panel")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleMiniPhrasePanel)
                MiniInfoView {
                    Text("recommend: Option-P").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Toggle mini custom entry panel")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleMiniEntryPanel)
                MiniInfoView {
                    Text("recommend: Option-E").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Show slots tab")
                Spacer()
                KeyboardShortcuts.Recorder(for: .showSlotsTab)
                MiniInfoView {
                    Text("recommend: Option-Z").font(.subheadline).padding()
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            g1
            g2
            g3
            g4
        }
        .toggleStyle(SwitchToggleStyle())
    }
}

struct ShortcutsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ShortcutsSettingsView()
    }
}
