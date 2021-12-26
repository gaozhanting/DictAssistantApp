//
//  VisionSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI
import Vision

struct MinimumTextHeightSetting: View {
    @AppStorage(MinimumTextHeightKey) var minimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315
    
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
            Text("Minimum Text Height:")
            
            Slider(
                value: $minimumTextHeight,
                in: 0...1
            )
            
            TextField("", value: $minimumTextHeight, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimum = 0
                formatter.maximum = 1
                return formatter
            }())
                .frame(width: tfWidth)
            
            Stepper(onIncrement: incrementStep, onDecrement: decrementStep) {}
            
            MiniInfoView(arrowEdge: .trailing) {
                HightInfoView()
            }
        }
    }
}

private struct HightInfoView: View {
    var body: some View {
        Text("Specify a floating-point number relative to the image height. \nFor example, to limit recognition to text that is half of the image height, use 0.5. Increasing the size reduces memory consumption and expedites recognition with the tradeoff of ignoring text smaller than the minimum height. \nThe default value is 1/32, or 0.03125.")
            .infoStyle()
    }
}

struct RecognitionLevelSetting: View {
    @AppStorage(RecognitionLevelKey) var textRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    
    var body: some View {
        HStack {
            Picker("Recognition Level:", selection: $textRecognitionLevel) {
                Text("fast").tag(VNRequestTextRecognitionLevel.fast.rawValue)
                Text("accurate").tag(VNRequestTextRecognitionLevel.accurate.rawValue)
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: 240)
            
            MiniInfoView {
                LevelInfoView()
            }
        }
    }
}

struct UsesLanguageCorrectionSetting: View {
    @AppStorage(UsesLanguageCorrectionKey) var usesLanguageCorrection: Bool = false
    
    var body: some View {
        HStack {
            Toggle("Uses Language Correction", isOn: $usesLanguageCorrection)
                .toggleStyle(CheckboxToggleStyle())
            MiniInfoView {
                UsesLanguageCorrectionInfoView()
            }
        }
    }
}

struct UsesLanguageCorrectionInfoView: View {
    var body: some View {
        Text("When this value is true, Vision applies language correction during the recognition process. Disabling this property returns the raw recognition results, which provides performance benefits but less accurate results.")
            .infoStyle()
    }
}

struct LevelInfoView: View {
    var body: some View {
        Text("The recognition level determines which techniques the request uses during the text recognition. Set this value to fast to prioritize speed over accuracy, and to accurate for longer, more computationally intensive recognition.")
            .infoStyle()
    }
}

struct VisionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LevelInfoView()
            UsesLanguageCorrectionInfoView()
            HightInfoView()
        }
        //        .environment(\.locale, .init(identifier: "zh-Hans"))
            .environment(\.locale, .init(identifier: "en"))
    }
}
