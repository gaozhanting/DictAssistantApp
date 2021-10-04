//
//  VisionSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI
import Vision
import Preferences

struct VisionSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: NSLocalizedString("Minimum Text Height:", comment: "")) {
                GroupBox {
                    VStack(alignment: .leading) {
                        TRMinimumTextHeightSetting()
                    }
                }
            }
            Preferences.Section(title: NSLocalizedString("Text Recognition Level:", comment: "")) {
                GroupBox {
                    VStack(alignment: .leading) {
                        TRTextRecognitionLevelSetting()
                    }
                }
            }
            Preferences.Section(title: NSLocalizedString("Maximum Frame Rate:", comment: "")) {
                MaximumFrameRateSetting()
            }
        }
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
            
            MiniInfoView(arrowEdge: .trailing) {
                MiniHeigthInfoPopoverView()
            }
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
            Text("Fast is very fast, and cause low CPU usage, you should use this by default, but terrible when text on screen has tough surrounding!")
                .preferenceDescription()
                .frame(width: 300, height: 50, alignment: .leading)
        } else {
            (Text("Accurate is the only rescue when the text is hard to recognized in screen! ")
                 + Text("Accurate will cause high CPU usage!").foregroundColor(.red))
                .preferenceDescription()
                .frame(width: 300, height: 50, alignment: .leading)
        }
    }
}

fileprivate struct MaximumFrameRateSetting: View {
    @AppStorage(MaximumFrameRateKey) private var maximumFrameRate: Double = 4
    @EnvironmentObject var statusData: StatusData
    
    var body: some View {
        HStack {
            TextField("", value: $maximumFrameRate, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .none // integer, no decimal
                formatter.minimum = 1
                formatter.maximum = 30
                return formatter
            }())
            .frame(width: 46)
            .disabled(statusData.isPlaying)
            
            Button("Use default") {
                maximumFrameRate = 4
            }
            .disabled(statusData.isPlaying)
            
            MiniInfoView(arrowEdge: Edge.trailing) {
                MaximumFrameRateInfoPopoverView()
            }
        }
    }
}

fileprivate struct MaximumFrameRateInfoPopoverView: View {
    var body: some View {
        Text("Set the maximum frame rate of the screen capture recording, default is 4fps which is a decent value for normal usage. \nThe higher the value, the more swift the APP react to the cropper screen content changing, but the more CPU it consumes. 1 to 30 is all OK.\nThe animation duration normally is 1/number. \nNotice, if you set a number less than 4, that will still use 4 as the fps, but the animation duration is still 1/number. \nNotice, if you need to set the text recognition level accurate at the same time, you need to set a lower value, for example 4. Because when set as a higher value, it maybe get stuck because it just can't do so much heavy lifting in such a little time.")
            .font(.subheadline)
            .padding()
            .frame(width: 300, height: 250)
    }
}

struct VisionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VisionSettingsView()
                .environmentObject(StatusData(isPlaying: false))

            MiniHeigthInfoPopoverView()
            
            MaximumFrameRateInfoPopoverView()
        }
            
    }
}
