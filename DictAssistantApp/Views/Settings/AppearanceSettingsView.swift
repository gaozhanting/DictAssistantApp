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
            Preferences.Section(title: "Toast:") {
                ShowToastToggle()
            }
            Preferences.Section(title: "Cropper Style:") {
                CropperStyleSettingView()
            }
            Preferences.Section(title: "Content Words Display:") {
                ShowCurrentKnownWordsToggle()
                ShowPhrasesToggle()
                AddLineBreakToggle()
            }
            Preferences.Section(title: "Content Window Shadow Display:") {
                ContentWindowShadowToggle()
            }
            Preferences.Section(title: "Content Animation Display:") {
                WithAnimationToggle()
            }
            Preferences.Section(title: "Content Style:") {
                ContentStyleSettingView()
            }
            Preferences.Section(title: "Font: ") {
                FontSettingView()
            }
            Preferences.Section(title: "Translation Font Rate:") {
                GroupBox {
                    VStack(alignment: .leading) {
                        FontRateSetting()
                    }
                }
            }
            Preferences.Section(title: "Appearance:") {
                ColorSchemeSetting()
            }
            Preferences.Section(title: "Colors & Shandow:") {
                GroupBox {
                    HStack {
                        GroupBox {
                            VStack(alignment: .trailing) {
                                WordColorPicker()
                                TransColorPicker()
                                BackgroundColorPicker()
                                TextShadowToggle()
                            }
                        }
                        .frame(width: 170)
                        
                        ShadowGroupSettings()
                    }
                }
            }
            Preferences.Section(title: "Content Background Display:") {
                ContentBackgroundVisualEffect()
            }
        }
    }
}

fileprivate struct ShowToastToggle: View {
    @AppStorage(ShowToastToggleKey) private var showToast: Bool = true
    
    var body: some View {
        Toggle(isOn: $showToast, label: {
            Text("Show Toast")
        })
        .toggleStyle(CheckboxToggleStyle())
    }
}

enum CropperStyle: Int, Codable {
    case closed = 0
    case rectangle = 1
}

fileprivate struct CropperStyleSettingView: View {
    @AppStorage(CropperStyleKey) private var cropperStyle: CropperStyle = .closed
    
    var bd: Binding<CropperStyle> {
        Binding.init {
            cropperStyle
        } set: { newValue in
            cropperStyle = newValue
            toggleCropperView()
        }
    }
    
    var body: some View {
        Picker("", selection: bd) {
            Text("closed").tag(CropperStyle.closed)
            Text("rectangle").tag(CropperStyle.rectangle)
        }
        .pickerStyle(MenuPickerStyle())
        .labelsHidden()
        .frame(width: 160)
    }
}

fileprivate struct FontSettingView: View {
    @AppStorage(FontKey) private var fontData: Data = fontToData(NSFont.systemFont(ofSize: 18.0))!
    
    func showFontPanel(_ sender: Any?) {
        let font = dataToFont(fontData)!
        
        NSFontManager.shared.setSelectedFont(font, isMultiple: false)
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSFontManager.shared.orderFrontFontPanel(sender)
    }
    
    var font: NSFont {
        dataToFont(fontData)!
    }
    
    var body: some View {
        HStack {
            TextField(
                "",
                text: Binding.constant("\(font.displayName!) \(font.pointSize)")
            )
            .disabled(true)
            .textFieldStyle(SquareBorderTextFieldStyle())
            .frame(maxWidth: 200)
            
            Button("Select...") {
                showFontPanel(nil)
            }
            
            Button("Use default") {
                let defaultFont = NSFont.systemFont(ofSize: 18.0)
                fontData = fontToData(defaultFont)!
            }
        }
    }
}

fileprivate struct FontRateSetting: View {
    @AppStorage(FontRateKey) private var fontRateKey: Double = 0.6
    
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
                in: 0...1
            )
            .frame(maxWidth: 180)
            
            Stepper(onIncrement: incrementStep, onDecrement: decrementStep) {}
        }
                
        Text("The font rate = fontSizeOfTranslation / fontSizeOfTheWord.")
            .preferenceDescription()
            .frame(width: 340, alignment: .leading)
    }
}

enum TheColorScheme: String, CaseIterable, Identifiable, Codable {
    case light
    case dark
    case system

    var id: String { self.rawValue }
}

fileprivate struct ColorSchemeSetting: View {
    @AppStorage(TheColorSchemeKey) private var theColorScheme: TheColorScheme = .system

    var body: some View {
        Picker("", selection: $theColorScheme) {
            Text("Light").tag(TheColorScheme.light)
            Text("Dark").tag(TheColorScheme.dark)
            Text("System").tag(TheColorScheme.system)
        }
        .labelsHidden()
        .pickerStyle(RadioGroupPickerStyle())
        .help("This will effect on visual effect background and system colors.")
    }
}

enum ContentStyle: Int, Codable {
    case portrait = 0
    case landscape = 1
}

enum PortraitCorner: Int, Codable {
    case topTrailing = 0
    case topLeading = 1
    case bottomLeading = 2
}

fileprivate struct ContentStyleSettingView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portrait
    
    @AppStorage(PortraitCornerKey) private var portraitCorner: PortraitCorner = .topTrailing
    
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 200.0
    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 260.0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("", selection: $contentStyle) {
                    Text("portrait").tag(ContentStyle.portrait)
                    Text("landscape").tag(ContentStyle.landscape)
                }
                .pickerStyle(MenuPickerStyle())
                .labelsHidden()
                .frame(width: 160)
                
                if contentStyle == .portrait {
                    Picker("with corner:", selection: $portraitCorner) {
                        Text("topTrailing").tag(PortraitCorner.topTrailing)
                        Text("topLeading").tag(PortraitCorner.topLeading)
                        Text("bottomLeading").tag(PortraitCorner.bottomLeading)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                }
            }

            switch contentStyle {
            case .portrait:
                HStack {
                    Text("max height for one word:")
                    TextField("", value: $portraitMaxHeight, formatter: formatter)
                        .frame(width: 46)
                }
            case .landscape:
                HStack {
                    Text("max width for one word:")
                    TextField("", value: $landscapeMaxWidth, formatter: formatter)
                        .frame(width: 46)
                }
                
            }
                        
        }
    }
}

fileprivate struct WordColorPicker: View {
    @AppStorage(WordColorKey) private var wordColor: Data = colorToData(NSColor.labelColor.withAlphaComponent(0.3))!
        
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
    @AppStorage(TransColorKey) private var transColor: Data = colorToData(NSColor.highlightColor)!
    
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
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.clear)!
    
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
            Text("Use Text Shadow")
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
                .frame(width: 140)
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

fileprivate struct ShowCurrentKnownWordsToggle: View {
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    
    var body: some View {
        Toggle(isOn: $isShowCurrentKnown, label: {
            Text("Show current known words")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want to display current known words.")
    }
}

fileprivate struct ShowPhrasesToggle: View {
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true
    
    var body: some View {
        Toggle(isOn: $isShowPhrase, label: {
            Text("Show phrases")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want display all phrase words.")
    }
}

fileprivate struct AddLineBreakToggle: View {
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    
    var body: some View {
        Toggle(isOn: $isAddLineBreak, label: {
            Text("Add line break")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you want add a line break between the word and the translation of the word.")
    }
}

fileprivate struct ContentWindowShadowToggle: View {
    @AppStorage(IsShowWindowShadowKey) private var isShowWindowShadow = false
    
    var bd: Binding<Bool> {
        Binding.init {
            isShowWindowShadow
        } set: { newValue in
            isShowWindowShadow = newValue
            toggleContentShadow()
        }
    }
    
    @State private var isShowingPopover = false
    
    var body: some View {
        HStack {
            Toggle(isOn: bd, label: {
                Text("Show Content Window Shadow")
            })
            .toggleStyle(CheckboxToggleStyle())
            .help("Select it when you prefer window shadow")
            
            Button(action: { isShowingPopover = true }, label: {
                Image(systemName: "info.circle")
            })
            .buttonStyle(PlainButtonStyle())
            .popover(isPresented: $isShowingPopover, content: {
                Text("Notice it may mess up.")
                    .font(.subheadline)
                    .padding()
            })
        }
    }
}

fileprivate struct ContentBackgroundVisualEffect: View {
    @AppStorage(ContentBackgroundVisualEffectKey) private var contentBackgroundVisualEffect: Bool = false

    var body: some View {
        HStack {
            Toggle(isOn: $contentBackgroundVisualEffect, label: {
                Text("Using Visual Effect")
            })
            .toggleStyle(SwitchToggleStyle())
            
            if contentBackgroundVisualEffect {
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

fileprivate struct WithAnimationToggle: View {
    @AppStorage(IsWithAnimationKey) private var isWithAnimation: Bool = true
        
    var body: some View {
        Toggle(isOn: $isWithAnimation, label: {
            Text("Show animation")
        })
        .toggleStyle(CheckboxToggleStyle())
        .help("Select it when you prefer animation for displaying words.")
    }
}

struct AppearanceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingsView()
            .frame(width: 650, height: 800)
    }
}
