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

private struct TagView: View {
    let txt: String
    
    var body: some View {
        Text(txt)
            .padding(.horizontal, 3)
            .background(Rectangle().fill(Color(NSColor.textBackgroundColor)).shadow(color: .primary, radius: 1))
    }
}

private struct ContentWindowLayoutTagView: View {
    @EnvironmentObject var contentWindowLayout: ContentWindowLayout

    var body: some View {
        switch contentWindowLayout.layout {
        case .portrait:
            TagView(txt: "portrait")
        case .landscape:
            TagView(txt: "landscape")
        }
    }
}

private struct ContentInnerLayoutTagView: View {
    @EnvironmentObject var contentWindowLayout: ContentWindowLayout
    @AppStorage(PortraitCornerKey) var portraitCorner: Int = PortraitCornerDefault
    @AppStorage(LandscapeStyleKey) var landscapeStyle: Int = LandscapeStyleDefault
    
    var body: some View {
        switch contentWindowLayout.layout {
        case .portrait:
            switch PortraitCorner(rawValue: portraitCorner)! {
            case .top:
                TagView(txt: "top")
            case .topTrailing:
                TagView(txt: "topTrailing")
            case .topLeading:
                TagView(txt: "topLeading")
            case .bottom:
                TagView(txt: "bottom")
            }
        case .landscape:
            switch LandscapeStyle(rawValue: landscapeStyle)! {
            case .scroll:
                TagView(txt: "scroll")
            case .centered:
                TagView(txt: "centered")
            }
        }
    }
}

private struct KeyRecordingView: View {
    @AppStorage(IsShowContentFrameKey) var isShowContentFrame: Bool = true
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
                    Text("recommend: Option-F\nThis option belongs to scene.").font(.subheadline).padding()
                }
            }
            HStack {
                Text("Switch content layout")
                Spacer()
                ContentWindowLayoutTagView()
                ContentInnerLayoutTagView()
                KeyboardShortcuts.Recorder(for: .switchLayout)
                MiniInfoView {
                    Text("recommend: Option-L\nSwitch content layout between top, topTrailing, topLeading and bottom when portrait; or scroll, centered when landscape. And whether it is landscape or portrait depends on which is bigger of the content window, width(landscape) or hight(portrait).\nThis option belongs to scene.")
                        .infoStyle()
                }
            }
            HStack {
                Text("Toggle add line break")
                Spacer()
                Toggle("", isOn: $isAddLineBreak)
                KeyboardShortcuts.Recorder(for: .toggleAddLineBreak)
                MiniInfoView {
                    Text("recommend: Option-B\nThis option belongs to scene.").font(.subheadline).padding()
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
                    Text("recommend: Option-3\nSet this true will still show the word which cannot be found in the dictionary.")
                        .infoStyle()
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
                Text("Run snapshot")
                Spacer()
                KeyboardShortcuts.Recorder(for: .runSnapshot)
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
