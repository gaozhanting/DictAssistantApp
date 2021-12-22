//
//  VisionSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/4.
//

import SwiftUI
import Vision

struct TRMinimumTextHeightSetting: View {
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

struct TRTextRecognitionLevelSetting: View {
    @AppStorage(TRTextRecognitionLevelKey) private var textRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    
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

struct LevelInfoView: View {
    var body: some View {
        (Text("Fast is very fast, and cause low CPU usage, you should use this by default. \nAccurate is the only rescue when the text is hard to be recognized on screen!")
         + Text("\nAccurate is cool when running cheap snapshot.").foregroundColor(Color(NSColor.systemPurple))
        + Text("\nAccurate will cause very high CPU usage when streaming!").foregroundColor(Color(NSColor.systemRed)))
            .infoStyle()
    }
}

struct VisionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HightInfoView()
            LevelInfoView()
        }
        //        .environment(\.locale, .init(identifier: "zh-Hans"))
            .environment(\.locale, .init(identifier: "en"))
    }
}
