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
    @AppStorage(TRMinimumTextHeightKey) private var minimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315
    
    func resetToDefault() {
        minimumTextHeight = systemDefaultMinimumTextHeight
    }
    
    func incrementStep() {
        minimumTextHeight += 0.01
        if minimumTextHeight > 1 {
            minimumTextHeight = 1
        }
    }
    
    func decrementStep() {
        minimumTextHeight -= 0.01
        if minimumTextHeight < 0 {
            minimumTextHeight = 0
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            
            HStack {
                Text("minimum text height: ")
                Text("\(minimumTextHeight)")
                Slider(
                    value: $minimumTextHeight,
                    in: 0...1
                )
                .frame(maxWidth: 180)
                
                Stepper(onIncrement: incrementStep, onDecrement: decrementStep) {}
                
            }
            
            Button("Reset to default: 0.0315", action: resetToDefault)
            
            Text("The minimum height of the text expected to be recognized, relative to the image height.")
                .font(.subheadline)
                .frame(maxWidth: 330)
                .help("Specify a floating-point number relative to the image height. For example, to limit recognition to text that is half of the image height, use 0.5. Increasing the size reduces memory consumption and expedites recognition with the tradeoff of ignoring text smaller than the minimum height. The default value is 1/32, or 0.03125.")
        }
        
    }
}

fileprivate struct TRTextRecognitionLevelSetting: View {
    @AppStorage(TRTextRecognitionLevelKey) private var textRecognitionLevel: VNRequestTextRecognitionLevel = .fast // fast 1, accurate 0
    
    var body: some View {
        VStack(alignment: .trailing) {
            Picker("Text recognition level: ", selection: $textRecognitionLevel) {
                Text("fast").tag(VNRequestTextRecognitionLevel.fast)
                Text("accurate").tag(VNRequestTextRecognitionLevel.accurate)
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: 400)
            
            if textRecognitionLevel == .fast {
                VStack(alignment: .trailing) {
                    Text("Fast is very fast, and cause low cpu usage, you should use this by default.").font(.subheadline).foregroundColor(.green)
                    Text("Fast recognition is terrible when text on screen has tough surrounding!").font(.subheadline).foregroundColor(.orange)
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
