//
//  AppearanceSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import SwiftUI
import Preferences

struct AppearanceSettingsView: View {
    var body: some View {
        VStack(alignment: .leading) {
            FontSettingView()
            
            FontRateSetting()

            ColorPickers()
            ShadowGroupSettings()

            ContentBackgroundColor()
            ContentBackgroundVisualEffect()

            ContentWindowShadowToggle()
            WithAnimationToggle()
            ContentRetentionToggle()

            ColorSchemeSetting()
        }
        .padding()
        .frame(width: panelWidth)
    }
}

private struct FontSettingView: View {
    @AppStorage(FontNameKey) private var fontName: String = defaultFontName
    @AppStorage(FontSizeKey) private var fontSize: Double = 14.0
    @AppStorage(LineSpacingKey) var lineSpacing: Double = 0
    
    var font: NSFont {
        if let font = NSFont(name: fontName, size: CGFloat(fontSize)) {
            return font
        } else {
            print("construct 3 font failed: with name:\(fontName), with size:\(fontSize)") // occured when changing default system font size; the FontPanel can't reflect the system font which is unkown why.
            return NSFont.systemFont(ofSize: 14.0)
        }
    }

    func showFontPanel(_ sender: Any?) {
        NSFontManager.shared.setSelectedFont(font, isMultiple: false)
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSFontManager.shared.orderFrontFontPanel(sender) // why the FontPanel has no system Font (same as CotEditor), but Apple Notes FontPanel does have.
    }
    
    var showFont: Font {
        return Font.custom(fontName, size: 13)
    }
    
    var body: some View {
        HStack {
            Text("Font:")
            TextField(
                "",
                text: Binding.constant("\(fontName) \(fontSize)")
            )
                .font(showFont)
                .disabled(true)
                .textFieldStyle(SquareBorderTextFieldStyle())
            
            Button("Select...") {
                showFontPanel(nil)
            }
            
            Button("Use default") {
                fontName = defaultFontName
                fontSize = 14.0
            }
            
            MiniInfoView {
                Text("There is a bug: when other TextField is focused, changing font is not work.")
                    .font(.subheadline)
                    .padding()
            }
        }
        
        HStack {
            Text("Font Line Spacing:")
            TextField("", value: $lineSpacing, formatter: tfDecimalFormatter).frame(width: tfWidth)
        }
    }
}

private struct FontRateSetting: View {
    @AppStorage(FontRateKey) private var fontRate: Double = 0.9
    
    func incrementStep() {
        fontRate += 0.01
        if fontRate > 1 {
            fontRate = 1
        }
    }
    
    func decrementStep() {
        fontRate -= 0.01
        if fontRate < 0 {
            fontRate = 0
        }
    }
    
    var body: some View {
        HStack {
            Text("Font Size Rate:")
            
            Slider(
                value: $fontRate,
                in: 0...2
            )
                .frame(maxWidth: 150)
            
//            Text("\(fontRate, specifier: "%.2f")")
            
            TextField("", value: $fontRate, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimum = 0
                formatter.maximum = 2
                return formatter
            }())
                .frame(width: tfWidth)
            
            Stepper(onIncrement: incrementStep, onDecrement: decrementStep) {}

            MiniInfoView {
                Text("The font size rate = font size of translation / font size of word.")
                    .font(.subheadline).padding()
            }
        }
    }
}

private struct ColorPickers: View {
    @AppStorage(WordColorKey) private var wordColor: Data = colorToData(NSColor.labelColor)!
    var colorBinding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(wordColor)!) },
            set: { newValue in
                wordColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    @AppStorage(TransColorKey) private var transColor: Data = colorToData(NSColor.secondaryLabelColor)!
    var transColorBinding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(transColor)!) },
            set: { newValue in
                transColor = colorToData(NSColor(newValue))!
            }
        )
    }

    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
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
        backgroundColor = colorToData(NSColor.windowBackgroundColor)!
    }
    
    var body: some View {
        HStack {
            ColorPicker("Word:", selection: colorBinding)
            Spacer()
            ColorPicker("Trans:", selection: transColorBinding)
            Spacer()
            ColorPicker("Background:", selection: bgColorBinding)
            Spacer()
            Button("Use Default") {
                useDefault()
            }
        }
    }
}

private struct ShadowGroupSettings: View {
    @AppStorage(TextShadowToggleKey) private var textShadowToggle: Bool = false
    
    var binding: Binding<Bool> {
        Binding(
            get: { textShadowToggle },
            set: { newValue in
                withAnimation {
                    textShadowToggle = newValue
                }
            }
        )
    }
    
    var body: some View {
        HStack {
            Toggle(isOn: binding, label: {
                Text("Use Text Shadow")
            })
            
            if textShadowToggle {
                Spacer()
                ShadowColorPicker()
                Text("R:")
                TextField("", value: $shadowRadius, formatter: tfDecimalFormatter).frame(width: tfWidth)
                Text("X:")
                TextField("", value: $shadowXOffset, formatter: tfDecimalFormatter).frame(width: tfWidth)
                Text("Y:")
                TextField("", value: $shadowYOffset, formatter: tfDecimalFormatter).frame(width: tfWidth)
            }
        }
    }
    
    @AppStorage(ShadowRadiusKey) private var shadowRadius: Double = 3
    @AppStorage(ShadowXOffSetKey) private var shadowXOffset: Double = 0
    @AppStorage(ShadowYOffSetKey) private var shadowYOffset: Double = 2
}

private struct ShadowColorPicker: View {
    @AppStorage(ShadowColorKey) private var shadowColor: Data = colorToData(NSColor.labelColor)!
    
    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(shadowColor)!) },
            set: { newValue in
                shadowColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    var body: some View {
        ColorPicker("Color:", selection: binding)
    }
}

private struct ContentBackgroundColor: View {
    @AppStorage(UseContentBackgroundColorKey) private var useContentBackgroundColor: Bool = true
    
    var body: some View {
        Toggle(isOn: $useContentBackgroundColor, label: {
            Text("Using Background Color")
        })
            .help("When selected, it will use the background color on all words.")
    }
}

private struct ContentBackgroundVisualEffect: View {
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false

    var body: some View {
        HStack {
            Toggle(isOn: $useContentBackgroundVisualEffect, label: {
                Text("Using Visual Effect")
            })
            
            Spacer()
            
            if useContentBackgroundVisualEffect {
                ContentBackGroundVisualEffectMaterial()
            }
        }
    }
}

private struct ContentBackGroundVisualEffectMaterial: View {
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    
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
        .frame(width: 220)
        .pickerStyle(MenuPickerStyle())
    }
}

private struct ColorSchemeSetting: View {
    @AppStorage(TheColorSchemeKey) private var theColorScheme: Int = TheColorScheme.system.rawValue

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
            .pickerStyle(MenuPickerStyle())
            .frame(width: 200)
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

private struct ContentWindowShadowToggle: View {
    @AppStorage(IsShowWindowShadowKey) private var isShowWindowShadow = false
    
    var body: some View {
        HStack {
            Toggle(isOn: $isShowWindowShadow, label: {
                Text("Show Content Window Shadow")
            })
            .toggleStyle(CheckboxToggleStyle())
            
//            MiniInfoView {
//                Text("Notice window shadow may mess up content.")
//                    .font(.subheadline)
//                    .padding()
//            }
        }
    }
}

private struct WithAnimationToggle: View {
    @AppStorage(IsWithAnimationKey) private var isWithAnimation: Bool = true
    
    var body: some View {
        HStack {
            Toggle(isOn: $isWithAnimation, label: {
                Text("With animation")
            })
            .toggleStyle(CheckboxToggleStyle())
            
//            MiniInfoView {
//                Text("Notice animation will increase CPU usage, and it may not be accurate with auto scrolling when using with landscape.")
//                    .font(.subheadline)
//                    .padding()
//            }
        }
    }
}

private struct ContentRetentionToggle: View {
    @AppStorage(IsContentRetentionKey) private var isContentRetention = false
    
    var body: some View {
        HStack {
            Toggle(isOn: $isContentRetention, label: {
                Text("Make Content Retention")
            })
            .toggleStyle(CheckboxToggleStyle())
            
//            MiniInfoView {
//                Text("If selected, content will get retention of last recognized tests when new recognized tests is empty.")
//                    .font(.subheadline)
//                    .padding()
//            }
        }
    }
}

struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
//        Group {
            AppearanceSettingsView()
            
//            ColorSchemeInfo()
//        }
        .environment(\.locale, .init(identifier: "en"))
//        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
