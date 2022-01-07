//
//  AppearanceSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import SwiftUI
import Preferences

struct AppearanceSettingsView: View {
    var g1: some View {
        Group {
            FontSettingView()
            FontRatioSetting()
            
            Spacer().frame(height: 20)
            Divider()
        }
    }
    
    var g2: some View {
        Group {
            ColorPickers()
            
            ContentBackgroundVisualEffect()
            ColorSchemeSetting()
            
            Spacer().frame(height: 20)
            Divider()
        }
    }
    
    var g3: some View {
        Group {
            WithAnimationToggle()
            IsShowToastView()
            ChineseCharacterConvertingPicker()
            
            Spacer().frame(height: 20)
            Divider()
        }
    }
    
    var g4: some View {
        Group {
            HighlightDottedOptionsView()
            HighlightDottedIndexOptionsView()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            g1
            g2
            g3
            g4
        }
        .padding()
        .frame(width: panelWidth)
    }
}

struct FontSizeSettingView: View {
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
            Text("Font Size:")
            TextField("", value: $fontSize, formatter: tfIntegerFormatter).frame(width: tfWidth)
            Stepper(onIncrement: onIncrement, onDecrement: onDecrement) {}
        }
    }
}

struct FontLineSpacingSettingView: View {
    @AppStorage(LineSpacingKey) var lineSpacing: Double = 2.0

    var body: some View {
        HStack {
            Text("Font Line Spacing:")
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
        Text("Here is only the font name you select from, not font size which is under the scenario tab. \nNote there is an issue: when other TextField is focused, changing font will not work, in that case, you could switch tabs and back.")
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
            Text("Font Size Trans/Word Ratio:")
            
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

private struct ColorPickers: View {
    @AppStorage(WordColorKey) var wordColor: Data = colorToData(NSColor.labelColor)!
    var colorBinding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(wordColor)!) },
            set: { newValue in
                wordColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    @AppStorage(TransColorKey) var transColor: Data = colorToData(NSColor.secondaryLabelColor)!
    var transColorBinding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(transColor)!) },
            set: { newValue in
                transColor = colorToData(NSColor(newValue))!
            }
        )
    }

    @AppStorage(BackgroundColorKey) var backgroundColor: Data = BackgroundColorDefault
    var bgColorBinding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(backgroundColor)!) },
            set: { newValue in
                backgroundColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    func useDefault() {
        wordColor = colorToData(NSColor.labelColor)!
        transColor = colorToData(NSColor.secondaryLabelColor)!
        backgroundColor = BackgroundColorDefault
    }
    
    var body: some View {
        HStack {
            ColorPicker("Word:", selection: colorBinding)
            Spacer()
            ColorPicker("Trans:", selection: transColorBinding)
            Spacer()
            ColorPicker("Background:", selection: bgColorBinding)
            Spacer()
            Button(action: useDefault) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

private struct ContentBackgroundVisualEffect: View {
    @AppStorage(UseContentBackgroundVisualEffectKey) var useContentBackgroundVisualEffect: Bool = false

    var body: some View {
        HStack {
            Toggle(isOn: $useContentBackgroundVisualEffect, label: {
                Text("Using Visual Effect")
            })
            
            Spacer()
            
            ContentBackGroundVisualEffectMaterial()
                .disabled(!useContentBackgroundVisualEffect)
        }
    }
}

private struct ContentBackGroundVisualEffectMaterial: View {
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    
    let allCases: [(Int, String)] = [
        (NSVisualEffectView.Material.titlebar.rawValue, "titlebar"),
        (NSVisualEffectView.Material.selection.rawValue, "selection"),
        (NSVisualEffectView.Material.menu.rawValue, "menu"),
        (NSVisualEffectView.Material.popover.rawValue, "popover"),
        (NSVisualEffectView.Material.sidebar.rawValue, "sidebar"),
        (NSVisualEffectView.Material.headerView.rawValue, "headerView"),
        (NSVisualEffectView.Material.sheet.rawValue, "sheet"),
        (NSVisualEffectView.Material.windowBackground.rawValue, "windowBackground"),
        (NSVisualEffectView.Material.hudWindow.rawValue, "hudWindow"),
        (NSVisualEffectView.Material.fullScreenUI.rawValue, "fullScreenUI"),
        (NSVisualEffectView.Material.toolTip.rawValue, "toolTip"),
        (NSVisualEffectView.Material.contentBackground.rawValue, "contentBackground"),
        (NSVisualEffectView.Material.underWindowBackground.rawValue, "underWindowBackground"),
        (NSVisualEffectView.Material.underPageBackground.rawValue, "underPageBackground")
    ]
    
    var body: some View {
        Picker("", selection: $contentBackGroundVisualEffectMaterial) {
            ForEach(allCases, id: \.self.0) { option in
                Text(option.1).tag(option.0)
            }
        }
        .frame(width: 200)
        .pickerStyle(MenuPickerStyle())
    }
}

private struct ColorSchemeSetting: View {
    @AppStorage(TheColorSchemeKey) var theColorScheme: Int = TheColorScheme.system.rawValue

    var body: some View {
        HStack {
            Text("Color Scheme")
            Spacer()
            Picker("", selection: $theColorScheme) {
                Text("Light").tag(TheColorScheme.light.rawValue)
                Text("Dark").tag(TheColorScheme.dark.rawValue)
                Text("System").tag(TheColorScheme.system.rawValue)
                Text("System Reversed").tag(TheColorScheme.systemReversed.rawValue)
            }
            .labelsHidden()
            .pickerStyle(MenuPickerStyle())
            .frame(width: 172)
            .help("This will effect on visual effect background and system colors.")
            
            MiniInfoView {
                ColorSchemeInfo()
            }
        }
    }
}

private struct ColorSchemeInfo: View {
    var body: some View {
        Text("Note: if you select System or System Reversed, then I suggest you select system color as well, otherwise, the color can't be adaptable both on light and dark system mode. You can open the color panel, select the Color Palettes tab, then select Developer option, the colors here are all system colors.")
            .infoStyle()
    }
}

private struct WithAnimationToggle: View {
    @AppStorage(IsWithAnimationKey) var isWithAnimation: Bool = true
    
    var body: some View {
        HStack {
            Toggle(isOn: $isWithAnimation, label: {
                Text("With Animation")
            })
            .toggleStyle(CheckboxToggleStyle())
            .help("Notice animation will increase CPU usage. And animation is disabled when using landscape with autoScrolling because it is ugly there.")
        }
    }
}

private struct IsShowToastView: View {
    @AppStorage(IsShowToastKey) var isShowToast: Bool = true
    
    var body: some View {
        Toggle(isOn: $isShowToast, label: {
            Text("Show Toast")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppearanceSettingsView()
            
            ColorSchemeInfo()
            
            FontInfoView()
        }
    }
}
