//
//  SettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/20.
//

import SwiftUI
import Vision

struct SettingsView: View {
    private let tabs = ["General", "Appearance"]
    @State private var selectedTabIndex = 0
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Picker("", selection: $selectedTabIndex) {
                    ForEach(tabs.indices) { i in
                        Text(tabs[i]).tag(i)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 8)
                Spacer()
            }
            
            Divider()
            
            GeometryReader { gp in // ???
                ChildTabView(
                    title: tabs[selectedTabIndex],
                    index: selectedTabIndex
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChildTabView: View {
    var title: String
    var index: Int
    
    var body: some View {
        if index == 0 {
            GeneralSettingView()
        } else if index == 1 {
            AppearanceSttingView()
        }
    }
}

struct GeneralSettingView: View {
    var body: some View {
        VStack {
            ShowPhraseToggle()
            TRMinimumTextHeightSetting()
            TRTextRecognitionLevelSetting()
        }
    }
}

fileprivate struct ShowPhraseToggle: View {
    @AppStorage("general:isShowPhrase") private var isShowPhrase: Bool = true
    
    var body: some View {
        Toggle(isOn: $isShowPhrase, label: {
            Text("Show Phrases")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

fileprivate struct TRMinimumTextHeightSetting: View {
    @AppStorage("TR:MinimumTextHeight") private var minimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315
    
    var body: some View {
        HStack {
            Text("minimum text height: ")
            Text("\(minimumTextHeight)")
            Slider(
                value: $minimumTextHeight,
                in: 0...1
            )
            .frame(maxWidth: 180)
        }
    }
}

fileprivate struct TRTextRecognitionLevelSetting: View {
    @AppStorage("TR:TextRecognitionLevel") private var textRecognitionLevel: VNRequestTextRecognitionLevel = .fast // fast 1, accurate 0
    
    var body: some View {
        VStack(alignment: .trailing) {
            Picker("text recognition level: ", selection: $textRecognitionLevel) {
                Text("fast").tag(VNRequestTextRecognitionLevel.fast)
                Text("accurate").tag(VNRequestTextRecognitionLevel.accurate)
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: 400)
            
            if textRecognitionLevel == .fast {
                VStack(alignment: .trailing) {
                    Text("Fast is very fast, and cause low cpu usage, you should use this by default.").font(.subheadline).foregroundColor(.green)
                    Text("Fast recognition is terrible when text on screen has tough surrounding!").font(.subheadline).foregroundColor(.red)
                }
            } else {
                VStack(alignment: .trailing) {
                    Text("Accurate is the only rescue when the text is hard to recognized in screen!").font(.subheadline).foregroundColor(.green)
                    Text("Accurate will cause high cpu usage!").font(.subheadline).foregroundColor(.red)
                }
            }
        }
    }
}

struct AppearanceSttingView: View {
    var body: some View {
        Text("appearance")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .frame(width: 500, height: 300)
    }
}
