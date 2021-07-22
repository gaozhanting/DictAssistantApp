//
//  GeneralSettingView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/22.
//

import SwiftUI
import Vision

struct GeneralSettingView: View {
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("Word display:")
                
                VStack(alignment: .leading) {
                    IsShowPhraseToggleSetting()
                    IsAddLineBreakSetting()
                    IsShowCurrentKnownSetting()
                    IsWithAnimationSetting()
                }
            }
            Divider()
            FontRateSetting()
            Divider()
            TRMinimumTextHeightSetting()
            Divider()
            TRTextRecognitionLevelSetting()
        }
        .padding(.horizontal)
    }
}

fileprivate struct IsShowPhraseToggleSetting: View {
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true
    
    var body: some View {
        Toggle(isOn: $isShowPhrase, label: {
            Text("Show phrases")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want display all phrase words.")
    }
}

fileprivate struct IsAddLineBreakSetting: View {
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreakKey: Bool = true
    
    var body: some View {
        Toggle(isOn: $isAddLineBreakKey, label: {
            Text("Add line break")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want add a line break between the word and the translation of the word.")
    }
}

fileprivate struct IsShowCurrentKnownSetting: View {
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    
    var body: some View {
        Toggle(isOn: $isShowCurrentKnown, label: {
            Text("Show current known words")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want to display current known words.")
    }
}

fileprivate struct IsWithAnimationSetting: View {
    @AppStorage(IsWithAnimationKey) private var isWithAnimation: Bool = true
        
    var body: some View {
        Toggle(isOn: $isWithAnimation, label: {
            Text("Show animation")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you prefer animation for displaying words.")
    }
    
}

fileprivate struct FontRateSetting: View {
    @AppStorage(FontRateKey) private var fontRateKey: Double = 0.6
    
    func resetToDefault() {
        fontRateKey = 0.6
    }
    
    func incrementStep() {
        fontRateKey += 0.01
        if fontRateKey > 1 {
            fontRateKey = 1
        }
    }
    
    func decrementStep() {
        fontRateKey -= 0.01
        if fontRateKey < 0 {
            fontRateKey = 0
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text("Font rate: \(fontRateKey, specifier: "%.2f")")
                Slider(
                    value: $fontRateKey,
                    in: 0...1
                )
                .frame(maxWidth: 180)
                
                Stepper(onIncrement: incrementStep, onDecrement: decrementStep) {}
            }
            
            Button("Reset to default: 0.6", action: resetToDefault)
            
            Text("The font rate = fontSizeOfTranslation / fontSizeOfTheWord.")
                .font(.subheadline)
                .frame(maxWidth: 330)
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
        VStack(alignment: .trailing) {
            
            HStack {
                Text("Minimum text height: \(minimumTextHeight, specifier: "%.4f")")
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

struct GeneralSettingView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingView()
    }
}
