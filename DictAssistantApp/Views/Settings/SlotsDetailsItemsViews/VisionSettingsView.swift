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
            Text("Min Height: \(minimumTextHeight, specifier: "%.4f")")
            Slider(
                value: $minimumTextHeight,
                in: 0...1
            )
//            .frame(maxWidth: 180)
            
            Stepper(onIncrement: incrementStep, onDecrement: decrementStep) {}
            
            MiniInfoView(arrowEdge: .trailing) {
                InfoView()
            }
        }
        
//        Button("Reset to default: 0.0315", action: resetToDefault)
        
//        HStack {
//            Text("The minimum height of the text expected to be recognized, relative to the image height.")
//                .preferenceDescription()
//                .frame(width: 300, height: 30, alignment: .leading)
            

//        }
    }
}

private struct InfoView: View {
    var body: some View {
        Text("Specify a floating-point number relative to the image height. \nFor example, to limit recognition to text that is half of the image height, use 0.5. Increasing the size reduces memory consumption and expedites recognition with the tradeoff of ignoring text smaller than the minimum height. \nThe default value is 1/32, or 0.03125.")
            .infoStyle()
    }
}

struct TRTextRecognitionLevelSetting: View {
    @AppStorage(TRTextRecognitionLevelKey) private var textRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    
    var body: some View {
        Picker("Level:", selection: $textRecognitionLevel) {
            Text("fast").tag(VNRequestTextRecognitionLevel.fast.rawValue)
            Text("accurate").tag(VNRequestTextRecognitionLevel.accurate.rawValue)
        }
        .pickerStyle(MenuPickerStyle())
//        .labelsHidden()
//        .frame(width: 160)
        
//        if textRecognitionLevel == VNRequestTextRecognitionLevel.fast.rawValue {
//            Text("Fast is very fast, and cause low CPU usage, you should use this by default, but terrible when text on screen has tough surrounding!")
//                .preferenceDescription()
//                .frame(width: 300, height: 50, alignment: .leading)
//        } else {
//            (Text("Accurate is the only rescue when the text is hard to recognized in screen! ")
//                 + Text("Accurate will cause high CPU usage!").foregroundColor(.red))
//                .preferenceDescription()
//                .frame(width: 300, height: 50, alignment: .leading)
//        }
    }
}

struct VisionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
        //        .environment(\.locale, .init(identifier: "zh-Hans"))
            .environment(\.locale, .init(identifier: "en"))
    }
}
