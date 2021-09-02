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

let settingPanelWidth: Double = 570.0

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
            Preferences.Section(title: "Maximum Frame Rate:") {
                MaximumFrameRateSetting()
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
                Text("Toggle Conceal Current Known Words:")
                Spacer()
                KeyboardShortcuts.Recorder(for: .toggleShowCurrentKnownWordsButWithOpacity0)
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
    @AppStorage(TRTextRecognitionLevelKey) private var textRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    
    var body: some View {
        Picker("", selection: $textRecognitionLevel) {
            Text("fast").tag(VNRequestTextRecognitionLevel.fast.rawValue)
            Text("accurate").tag(VNRequestTextRecognitionLevel.accurate.rawValue)
        }
        .pickerStyle(MenuPickerStyle())
        .labelsHidden()
        .frame(width: 160)
        
        if textRecognitionLevel == VNRequestTextRecognitionLevel.fast.rawValue {
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

fileprivate struct MaximumFrameRateSetting: View {
    @AppStorage(MaximumFrameRateKey) private var maximumFrameRate: Double = 4
    @EnvironmentObject var statusData: StatusData
    var isPlaying: Bool {
        statusData.isPlaying
    }
    
    @State private var isShowingPopover = false
    
    var body: some View {
        HStack {
            TextField("", value: $maximumFrameRate, formatter: formatter)
                .frame(width: 46)
                .disabled(isPlaying)
            
            Button("Use default") {
                maximumFrameRate = 4
            }
            .disabled(isPlaying)
            
            Button(action: { isShowingPopover = true }, label: {
                Image(systemName: "info.circle")
            })
            .buttonStyle(PlainButtonStyle())
            .popover(isPresented: $isShowingPopover, arrowEdge: .trailing, content: {
                MaximumFrameRateInfoPopoverView()
            })
        }
    }
}

fileprivate struct MaximumFrameRateInfoPopoverView: View {
    var body: some View {
        Text("Set the maximum frame rate of the screen capture recording, default is 4fps which is a decent value for normal usage. \nThe higher the value, the more swift the app react to the cropper screen content changing, but the more cpu it consumes. 4 to 30 is all OK, and number below 4 is useless. \nNotice, if you need to set the text recognition level accurate at the same time, you need to set a lower value, for example 4. Because when set as a higher value, it maybe get stuck because it just can't do so much heavy lift in such a little time.")
            .font(.subheadline)
            .padding()
            .frame(width: 300, height: 230)
    }
}

struct GeneralSettingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GeneralSettingsView()
                .environmentObject(StatusData(isPlaying: false))
                .frame(width: 650, height: 500)
            
            MiniHeigthInfoPopoverView()
            
            MaximumFrameRateInfoPopoverView()
        }
    }
}
