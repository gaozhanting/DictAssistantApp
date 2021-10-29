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
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: NSLocalizedString("Content Style:", comment: "")) {
                ContentStyleSettingView()
            }
            Preferences.Section(title: NSLocalizedString("Font: ", comment: "")) {
                FontSettingView()
            }
            Preferences.Section(title: NSLocalizedString("Translation Font Rate:", comment: "")) {
                GroupBox {
                    VStack(alignment: .leading) {
                        FontRateSetting()
                    }
                }
            }
            Preferences.Section(title: NSLocalizedString("Colors & Shadow:", comment: "")) {
                GroupBox {
                    HStack {
                        GroupBox {
                            VStack(alignment: .trailing) {
                                WordColorPicker()
                                TransColorPicker()
                                BackgroundColorPicker()
                                TextShadowToggle()
                            }
                            .frame(width: 160)
                        }
                        
                        ShadowGroupSettings()
                    }
                }
            }
            Preferences.Section(title: NSLocalizedString("Content Background Display:", comment: "")) {
                ContentBackgroundColor()
                ContentBackgroundVisualEffect()
            }
            Preferences.Section(title: NSLocalizedString("Appearance:", comment: "")) {
                ColorSchemeSetting()
            }
            Preferences.Section(title: NSLocalizedString("Content Window Shadow Display:", comment: "")) {
                ContentWindowShadowToggle()
            }
            Preferences.Section(title: NSLocalizedString("Content Animation Display:", comment: "")) {
                WithAnimationToggle()
            }
            Preferences.Section(title: NSLocalizedString("Content Retention:", comment: "")) {
                ContentRetentionToggle()
            }
        }
    }
}

fileprivate struct ContentRetentionToggle: View {
    @AppStorage(IsContentRetentionKey) private var isContentRetention = false
    
    var body: some View {
        HStack {
            Toggle(isOn: $isContentRetention, label: {
                Text("Make Content Retention")
            })
            .toggleStyle(CheckboxToggleStyle())
            
            MiniInfoView {
                Text("If selected, content will get retention of last recognized tests when new recognized tests is empty.")
                    .font(.subheadline)
                    .padding()
            }
        }
    }
}

fileprivate struct ContentWindowShadowToggle: View {
    @AppStorage(IsShowWindowShadowKey) private var isShowWindowShadow = false
    
    var body: some View {
        HStack {
            Toggle(isOn: $isShowWindowShadow, label: {
                Text("Show Content Window Shadow")
            })
            .toggleStyle(CheckboxToggleStyle())
            
            MiniInfoView {
                Text("Notice window shadow may mess up content.")
                    .font(.subheadline)
                    .padding()
            }
        }
    }
}

fileprivate struct WithAnimationToggle: View {
    @AppStorage(IsWithAnimationKey) private var isWithAnimation: Bool = true
    
    var body: some View {
        HStack {
            Toggle(isOn: $isWithAnimation, label: {
                Text("With animation")
            })
            .toggleStyle(CheckboxToggleStyle())
            
            MiniInfoView {
                Text("Notice animation will increase CPU usage, and it may not be accurate with auto scrolling when using with landscape.")
                    .font(.subheadline)
                    .padding()
            }
        }
    }
}

fileprivate struct ContentStyleSettingView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: Int = ContentStyle.portrait.rawValue

    @AppStorage(PortraitCornerKey) private var portraitCorner: Int = PortraitCorner.topTrailing.rawValue
    @AppStorage(LandscapeAutoScrollKey) private var landscapeAutoScroll: Bool = true
    
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 100.0
    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 160.0

    @State private var isShowTextField: Bool = false
    
    var binding: Binding<Bool> {
        Binding(
            get: { isShowTextField },
            set: { newValue in
                withAnimation {
                    isShowTextField = newValue
                }
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("", selection: $contentStyle) {
                    Text("portrait").tag(ContentStyle.portrait.rawValue)
                    Text("landscape").tag(ContentStyle.landscape.rawValue)
                }
                .pickerStyle(MenuPickerStyle())
                .labelsHidden()
                .frame(width: 160)
                
                switch ContentStyle(rawValue: contentStyle)! {
                case .portrait:
                    Picker("from corner:", selection: $portraitCorner) {
                        Text("topTrailing").tag(PortraitCorner.topTrailing.rawValue)
                        Text("topLeading").tag(PortraitCorner.topLeading.rawValue)
                        Text("bottomLeading").tag(PortraitCorner.bottomLeading.rawValue)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                case .landscape:
                    Picker("auto scroll:", selection: $landscapeAutoScroll) {
                        Text("enabled").tag(true)
                        Text("disabled").tag(false)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                }
            }
            
            HStack {
                Toggle(isOn: binding, label: {
                    Text("More...")
                })
                .toggleStyle(SwitchToggleStyle())
                
                Spacer()
                
                if isShowTextField {
                    switch ContentStyle(rawValue: contentStyle)! {
                    case .portrait:
                        Text("max height for one word:")
                        TextField("", value: $portraitMaxHeight, formatter: {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .none // integer, no decimal
                            formatter.minimum = 1
                            formatter.maximum = 1000
                            return formatter
                        }(), onCommit: { isShowTextField = false })
                        .frame(width: 46)
                    case .landscape:
                        Text("max width for one word:")
                        TextField("", value: $landscapeMaxWidth, formatter: {
                            let formatter = NumberFormatter()
                            formatter.numberStyle = .none // integer, no decimal
                            formatter.minimum = 1
                            formatter.maximum = 1000
                            return formatter
                        }(), onCommit: { isShowTextField = false })
                        .frame(width: 46)
                    }
                }
            }
            .frame(width: 370)
        }
    }
}

fileprivate struct FontSettingView: View {
    @AppStorage(FontNameKey) private var fontName: String = defaultFontName
    @AppStorage(FontSizeKey) private var fontSize: Double = 18.0
    
    var font: NSFont {
        if let font = NSFont(name: fontName, size: CGFloat(fontSize)) {
            return font
        } else {
            print("construct 3 font failed: with name:\(fontName), with size:\(fontSize)") // occured when changing default system font size; the FontPanel can't reflect the system font which is unkown why.
            return NSFont.systemFont(ofSize: 18.0)
        }
    }

    func showFontPanel(_ sender: Any?) {
        NSFontManager.shared.setSelectedFont(font, isMultiple: false)
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSFontManager.shared.orderFrontFontPanel(sender) // why the FontPanel has no system Font (same as CotEditor), but Apple Notes FontPanel does have.
    }
    
    var body: some View {
        HStack {
            TextField(
                "",
                text: Binding.constant("\(fontName) \(fontSize)")
            )
            .disabled(true)
            .textFieldStyle(SquareBorderTextFieldStyle())
            .frame(maxWidth: 200)
            
            Button("Select...") {
                showFontPanel(nil)
            }
            
            Button("Use default") {
                fontName = defaultFontName
                fontSize = 18.0
            }
        }
    }
}

fileprivate struct FontRateSetting: View {
    @AppStorage(FontRateKey) private var fontRateKey: Double = 0.75
    
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
        HStack {
            Text("\(fontRateKey, specifier: "%.2f")")
            Slider(
                value: $fontRateKey,
                in: 0...2
            )
            .frame(maxWidth: 180)
            
            Stepper(onIncrement: incrementStep, onDecrement: decrementStep) {}
        }
                
        Text("The font rate = fontSizeOfTranslation / fontSizeOfTheWord.")
            .preferenceDescription()
            .frame(width: 340, alignment: .leading)
    }
}

fileprivate struct ColorSchemeSetting: View {
    @AppStorage(TheColorSchemeKey) private var theColorScheme: Int = TheColorScheme.system.rawValue

    var body: some View {
        Picker("", selection: $theColorScheme) {
            Text("Light").tag(TheColorScheme.light.rawValue)
            Text("Dark").tag(TheColorScheme.dark.rawValue)
            Text("System").tag(TheColorScheme.system.rawValue)
        }
        .labelsHidden()
        .pickerStyle(MenuPickerStyle())
        .frame(width: 160)
        .help("This will effect on visual effect background and system colors.")
    }
}

fileprivate struct WordColorPicker: View {
    @AppStorage(WordColorKey) private var wordColor: Data = colorToData(NSColor.labelColor)!
        
    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(wordColor)!) },
            set: { newValue in
                wordColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    var body: some View {
        ColorPicker("Word:", selection: binding)
    }
}

fileprivate struct TransColorPicker: View {
    @AppStorage(TransColorKey) private var transColor: Data = colorToData(NSColor.secondaryLabelColor)!
    
    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(transColor)!) },
            set: { newValue in
                transColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    var body: some View {
        ColorPicker("Translation:", selection: binding)
    }
}

fileprivate struct BackgroundColorPicker: View {
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    
    var binding: Binding<Color> {
        Binding(
            get: { Color(dataToColor(backgroundColor)!) },
            set: { newValue in
                backgroundColor = colorToData(NSColor(newValue))!
            }
        )
    }
    
    var body: some View {
        ColorPicker("Background:", selection: binding)
    }
}

fileprivate struct TextShadowToggle: View {
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
        Toggle(isOn: binding, label: {
            Text("Use Text Shadow:")
        })
        .toggleStyle(SwitchToggleStyle())
    }
}

fileprivate struct ShadowGroupSettings: View {
    @AppStorage(TextShadowToggleKey) private var textShadowToggle: Bool = false

    var body: some View {
        if textShadowToggle {
            GroupBox {
                VStack(alignment: .trailing) {
                    ShadowColorPicker()
                    ShadowRadiusPicker()
                    ShadowXOffSetPicker()
                    ShadowYOffSetPicker()
                }
                .frame(width: 130)
            }
        }
    }
}

fileprivate struct ShadowColorPicker: View {
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

let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimum = 0.0
    return formatter
}()

fileprivate struct ShadowRadiusPicker: View {
    @AppStorage(ShadowRadiusKey) private var shadowRadius: Double = 3
    
    var body: some View {
        HStack {
            Spacer()
            Text("Radius:")
            TextField("", value: $shadowRadius, formatter: formatter)
                .frame(maxWidth: 46)
        }
    }
}

fileprivate struct ShadowXOffSetPicker: View {
    @AppStorage(ShadowXOffSetKey) private var shadowXOffset: Double = 0
    var body: some View {
        HStack {
            Spacer()
            Text("X Offset:")
            TextField("", value: $shadowXOffset, formatter: formatter)
                .frame(maxWidth: 46)
        }
    }
}

fileprivate struct ShadowYOffSetPicker: View {
    @AppStorage(ShadowYOffSetKey) private var shadowYOffset: Double = 2

    var body: some View {
        HStack {
            Spacer()
            Text("Y Offset:")
            TextField("", value: $shadowYOffset, formatter: formatter)
                .frame(maxWidth: 46)
        }
    }
}

private struct ContentBackgroundColor: View {
    @AppStorage(UseContentBackgroundColorKey) private var useContentBackgroundColor: Bool = true
    
    var body: some View {
        Toggle(isOn: $useContentBackgroundColor, label: {
            Text("Using Background Color")
        })
            .toggleStyle(SwitchToggleStyle())
            .help("When selected, it will use the background color on all words.")
    }
}

fileprivate struct ContentBackgroundVisualEffect: View {
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false

    var body: some View {
        HStack {
            Toggle(isOn: $useContentBackgroundVisualEffect, label: {
                Text("Using Visual Effect")
            })
                .toggleStyle(SwitchToggleStyle())
            
            if useContentBackgroundVisualEffect {
                ContentBackGroundVisualEffectMaterial()
                    .frame(maxWidth: 200)
            }
        }
    }
}

fileprivate struct ContentBackGroundVisualEffectMaterial: View {
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
        Picker("with material:", selection: $contentBackGroundVisualEffectMaterial) {
            ForEach(allCases, id: \.self.0) { option in
                Text(option.1).tag(option.0)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppearanceSettingsView()
                .environment(\.locale, .init(identifier: "en"))
            
            AppearanceSettingsView()
                .environment(\.locale, .init(identifier: "zh-Hans"))

            AppearanceSettingsView()
                .environment(\.locale, .init(identifier: "zh-Hant"))
        }
            .frame(width: 650, height: 800)
    }
}
