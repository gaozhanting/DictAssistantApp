//
//  GeneralSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/22.
//

import SwiftUI
import Vision
import Preferences
import KeyboardShortcuts

let settingPanelWidth: Double = 600.0

struct GeneralSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: "Short Cut Key:") {
                KeyRecordingView()
            }
            Preferences.Section(title: "Minimum Text Height:") {
                GroupBox {
                    VStack(alignment: .leading) {
                        TRMinimumTextHeightSetting()
                    }
                }
            }
            Preferences.Section(title: "Text Recognition Level:") {
                GroupBox {
                    VStack(alignment: .leading) {
                        TRTextRecognitionLevelSetting()
                    }
                }
            }
            Preferences.Section(title: "Speak:") {
                SpeakWordToggle()
            }
        }
    }
}

fileprivate struct KeyRecordingView: View {
    var body: some View {
        Group {
            HStack {
                Text("Toggle Unicorn Mode:")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleUnicornMode)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Toggle Show Current Known Words:")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleShowCurrentKnownWords)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Reload Content View:")
                Spacer()
                KeyboardShortcuts.Recorder(for: .reloadContentView)
            }
        }
        .frame(maxWidth: 380)
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
    
    @State private var isShowingPopover = false
    
    var body: some View {
        HStack {
            Text("\(minimumTextHeight, specifier: "%.4f")")
            Slider(
                value: $minimumTextHeight,
                in: 0...1
            )
            .frame(maxWidth: 180)
            
            Stepper(onIncrement: incrementStep, onDecrement: decrementStep) {}
        }
        
        Button("Reset to default: 0.0315", action: resetToDefault)
        
        HStack {
            Text("The minimum height of the text expected to be recognized, relative to the image height.")
                .preferenceDescription()
                .frame(width: 300, height: 30, alignment: .leading)
            
            Button(action: { isShowingPopover = true }, label: {
                Image(systemName: "info.circle")
            })
            .buttonStyle(PlainButtonStyle())
            .popover(isPresented: $isShowingPopover, arrowEdge: .trailing, content: {
                MiniHeigthInfoPopoverView()
            })
        }
    }
}

fileprivate struct MiniHeigthInfoPopoverView: View {
    var body: some View {
        Text("Specify a floating-point number relative to the image height. \nFor example, to limit recognition to text that is half of the image height, use 0.5. Increasing the size reduces memory consumption and expedites recognition with the tradeoff of ignoring text smaller than the minimum height. \nThe default value is 1/32, or 0.03125.")
            .font(.subheadline)
            .padding()
            .frame(width: 300, height: 150)
    }
}

fileprivate struct TRTextRecognitionLevelSetting: View {
    @AppStorage(TRTextRecognitionLevelKey) private var textRecognitionLevel: VNRequestTextRecognitionLevel = .fast // fast 1, accurate 0
    
    var body: some View {
        Picker("", selection: $textRecognitionLevel) {
            Text("fast").tag(VNRequestTextRecognitionLevel.fast)
            Text("accurate").tag(VNRequestTextRecognitionLevel.accurate)
        }
        .pickerStyle(MenuPickerStyle())
        .labelsHidden()
        .frame(width: 160)
        
        if textRecognitionLevel == .fast {
            Text("Fast is very fast, and cause low cpu usage, you should use this by default, but terrible when text on screen has tough surrounding!")
                .preferenceDescription()
                .frame(width: 300, height: 50, alignment: .leading)
        } else {
            (Text("Accurate is the only rescue when the text is hard to recognized in screen! ")
                 + Text("Accurate will cause high cpu usage!").foregroundColor(.red))
                .preferenceDescription()
                .frame(width: 300, height: 50, alignment: .leading)
        }
    }
}

fileprivate struct SpeakWordToggle: View {
    @AppStorage(SpeakWordToggleKey) private var speakWordToggle: Bool = false
    
    var body: some View {
        Toggle(isOn: $speakWordToggle, label: {
            Text("Speak word when long tap")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

struct GeneralSettingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GeneralSettingsView()
                .frame(width: 650, height: 500)
            
            MiniHeigthInfoPopoverView()
        }
    }
}
