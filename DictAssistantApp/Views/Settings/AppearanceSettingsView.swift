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
                    HStack(alignment: .top) {
                        ColorPickers()
                        ShadowGroupSettings()
                    }
                }
                .frame(width: 360)
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

private struct FontSettingView: View {
    @AppStorage(FontNameKey) private var fontName: String = defaultFontName
    @AppStorage(FontSizeKey) private var fontSize: Double = 14.0
    
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
        VStack(alignment: .leading) {
            HStack {
                TextField(
                    "",
                    text: Binding.constant("\(fontName) \(fontSize)")
                )
                    .font(showFont)
                    .disabled(true)
                    .textFieldStyle(SquareBorderTextFieldStyle())
                    .frame(maxWidth: 200)
                
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
                Toggle(isOn: binding, label: {
                    Text("More...")
                })
                    .toggleStyle(SwitchToggleStyle())
                
                Spacer()
                
                if isShowTextField {
                    Text("line spacing:")
                    LineSpacingView(fold: fold)
                        .frame(width: 30)
                }
            }
            .frame(width: 280)
        }
    }
    
    func fold() {
        isShowTextField = false
    }
    
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
}

private struct LineSpacingView: View {
    let fold: () -> Void
    
    @AppStorage(LineSpacingKey) var lineSpacing: Double = 0
    
    @State var showingAlert: Bool = false
    
    var binding: Binding<String> {
        Binding(
            get: { String(lineSpacing) },
            set: { newValue in
                guard let newValue = Double(newValue) else {
                    showingAlert = true
                    return
                }
                
                lineSpacing = newValue
            }
        )
    }
    
    var body: some View {
        TextField("", text: binding, onCommit: fold)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Invalid value"), message: Text("Value must be number"))
            }
        
    }
}

private struct FontRateSetting: View {
    @AppStorage(FontRateKey) private var fontRateKey: Double = 0.9
    
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
        GroupBox {
            VStack {
                HStack {
                    Spacer()
                    ColorPicker("Word:", selection: colorBinding)
                }
                HStack {
                    Spacer()
                    ColorPicker("Translation:", selection: transColorBinding)
                }
                HStack {
                    Spacer()
                    ColorPicker("Background:", selection: bgColorBinding)
                }
                HStack {
                    Spacer()
                    Button("Use Default") {
                        useDefault()
                    }
                }
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
        GroupBox {
            VStack {
                HStack {
                    Spacer()
                    Toggle(isOn: binding, label: {
                        Text("Use Text Shadow")
                    })
                        .toggleStyle(SwitchToggleStyle())
                }
                
                if textShadowToggle {
                    ShadowColorPicker()
                    ShadowRadiusPicker()
                    ShadowXOffSetPicker()
                    ShadowYOffSetPicker()
                }
            }
        }
    }
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
        HStack {
            Spacer()
            ColorPicker("Color:", selection: binding)
        }
    }
}

private struct ShadowRadiusPicker: View {
    @AppStorage(ShadowRadiusKey) private var shadowRadius: Double = 3
    
    @State var showingAlert: Bool = false
    
    var binding: Binding<String> {
        Binding(
            get: { String(shadowRadius) },
            set: { newValue in
                guard let newValue = Double(newValue) else {
                    showingAlert = true
                    return
                }
                
                shadowRadius = newValue
            }
        )
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text("Radius:")
            TextField("", text: binding)
                .frame(maxWidth: 46)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Invalid value"), message: Text("Value must be a number."))
                }
        }
    }
}

private struct ShadowXOffSetPicker: View {
    @AppStorage(ShadowXOffSetKey) private var shadowXOffset: Double = 0
    
    @State var showingAlert: Bool = false
    
    var binding: Binding<String> {
        Binding(
            get: { String(shadowXOffset) },
            set: { newValue in
                guard let newValue = Double(newValue) else {
                    showingAlert = true
                    return
                }
                
                shadowXOffset = newValue
            }
        )
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text("X Offset:")
            TextField("", text: binding)
                .frame(maxWidth: 46)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Invalid value"), message: Text("Value must be a number"))
                }
        }
    }
}

private struct ShadowYOffSetPicker: View {
    @AppStorage(ShadowYOffSetKey) private var shadowYOffset: Double = 2
    
    @State var showingAlert: Bool = false
    
    var binding: Binding<String> {
        Binding(
            get: { String(shadowYOffset) },
            set: { newValue in
                guard let newValue = Double(newValue) else {
                    showingAlert = true
                    return
                }
                
                shadowYOffset = newValue
            }
        )
    }

    var body: some View {
        HStack {
            Spacer()
            Text("Y Offset:")
            TextField("", text: binding)
                .frame(maxWidth: 46)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Invalid value"), message: Text("Value must be a number"))
                }
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

private struct ContentBackgroundVisualEffect: View {
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
        Picker("with material:", selection: $contentBackGroundVisualEffectMaterial) {
            ForEach(allCases, id: \.self.0) { option in
                Text(option.1).tag(option.0)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

private struct ColorSchemeSetting: View {
    @AppStorage(TheColorSchemeKey) private var theColorScheme: Int = TheColorScheme.system.rawValue

    var body: some View {
        HStack {
            Picker("", selection: $theColorScheme) {
                Text("Light").tag(TheColorScheme.light.rawValue)
                Text("Dark").tag(TheColorScheme.dark.rawValue)
                Text("System").tag(TheColorScheme.system.rawValue)
                Text("System Reversed").tag(TheColorScheme.systemReversed.rawValue)
            }
            .labelsHidden()
            .pickerStyle(MenuPickerStyle())
            .frame(width: 160)
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
            
            MiniInfoView {
                Text("Notice window shadow may mess up content.")
                    .font(.subheadline)
                    .padding()
            }
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
            
            MiniInfoView {
                Text("Notice animation will increase CPU usage, and it may not be accurate with auto scrolling when using with landscape.")
                    .font(.subheadline)
                    .padding()
            }
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
            
            MiniInfoView {
                Text("If selected, content will get retention of last recognized tests when new recognized tests is empty.")
                    .font(.subheadline)
                    .padding()
            }
        }
    }
}

struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppearanceSettingsView()
            
            ColorSchemeInfo()
        }
        .environment(\.locale, .init(identifier: "en"))
//        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
