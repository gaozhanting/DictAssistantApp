//
//  CommonSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/24.
//

import SwiftUI

struct CommonSettingsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            UseAppleDictModePicker()
            UseEntryModePicker()
            
            DoNameRecognitionToggle()
            DoPhraseDetectionToggle()
            
            Divider()
            
            FontSettingView()
            FontRatioSetting()
            
            WithAnimationToggle()
            ChineseCharacterConvertingPicker()
            HighlightDottedView()
        }
        .padding()
        .frame(width: panelWidth)
    }
}

struct FontConfigView: View {
    var body: some View {
        HStack {
            FontSizeSettingView()
            Spacer()
            FontLineSpacingSettingView()
        }
    }
}

private struct FontSizeSettingView: View {
    @AppStorage(FontSizeKey) var fontSize: Int = 14
    
    func onIncrement() {
        fontSize += 1
    }
    
    func onDecrement() {
        fontSize -= 1
        if fontSize < 0 {
            fontSize = 0
        }
    }
    
    var body: some View {
        HStack {
            Text("Font size:")
            TextField("", value: $fontSize, formatter: tfIntegerFormatter).frame(width: tfWidth)
            Stepper(onIncrement: onIncrement, onDecrement: onDecrement) {}
        }
    }
}

private struct FontLineSpacingSettingView: View {
    @AppStorage(LineSpacingKey) var lineSpacing: Double = 2.0

    var body: some View {
        HStack {
            Text("Font line spacing:")
            TextField("", value: $lineSpacing, formatter: tfDecimalFormatter).frame(width: tfSmallWidth)
        }
    }
}

private struct FontSettingView: View {
    @AppStorage(FontNameKey) var fontName: String = defaultFontName
    let fixedFontSize: Int = 13
    
    var font: NSFont {
        if let font = NSFont(name: fontName, size: CGFloat(fixedFontSize)) {
            return font
        } else {
            print("construct 3 font failed: with name:\(fontName), with size:\(fixedFontSize)") // occured when changing default system font size; the FontPanel can't reflect the system font which is unkown why.
            return NSFont.systemFont(ofSize: 14.0)
        }
    }

    func showFontPanel(_ sender: Any?) {
        NSFontManager.shared.setSelectedFont(font, isMultiple: false)
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSFontManager.shared.orderFrontFontPanel(sender) // why the FontPanel has no system Font (same as CotEditor), but Apple Notes FontPanel does have.
    }
    
    var showFont: Font {
        return Font.custom(fontName, size: CGFloat(fixedFontSize))
    }
    
    func useDefault() {
        fontName = defaultFontName
    }
    
    var body: some View {
        HStack {
            Text("Font:")
            TextField("", text: Binding.constant("\(fontName)"))
                .font(showFont)
                .disabled(true)
                .textFieldStyle(SquareBorderTextFieldStyle())
            
            Button("Select...") {
                showFontPanel(nil)
            }
            
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
            
            MiniInfoView {
                FontInfoView()
            }
        }
    }
}

private struct FontInfoView: View {
    var body: some View {
        Text("Here is only the font name you select from, not font size which is under the Scene Tab. \nNote there is an issue: when other TextField is focused, changing font will not work, in that case, you could switch tabs and back.")
            .infoStyle()
    }
}

private struct FontRatioSetting: View {
    @AppStorage(FontRatioKey) var fontRatio: Double = 0.9
    
    func incrementStep() {
        fontRatio += 0.01
        if fontRatio > 1 {
            fontRatio = 1
        }
    }
    
    func decrementStep() {
        fontRatio -= 0.01
        if fontRatio < 0 {
            fontRatio = 0
        }
    }
    
    var body: some View {
        HStack {
            Text("Font size - Trans/Word ratio:")
            
            Slider(
                value: $fontRatio,
                in: 0...2
            )
            
            TextField("", value: $fontRatio, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimum = 0
                formatter.maximum = 2
                return formatter
            }())
                .frame(width: tfWidth)
            
            Stepper(onIncrement: incrementStep, onDecrement: decrementStep) {}
        }
    }
}

private struct WithAnimationToggle: View {
    @AppStorage(IsWithAnimationKey) var isWithAnimation: Bool = true
    
    var body: some View {
        HStack {
            Toggle(isOn: $isWithAnimation, label: {
                Text("With animation")
            })
            .toggleStyle(CheckboxToggleStyle())
        }
    }
}

struct CommonSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CommonSettingsView()
            
            FontInfoView()
        }
    }
}
