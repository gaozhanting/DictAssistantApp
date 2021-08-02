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
            Preferences.Section(title: "Show Toast:") {
                ShowToastToggle()
            }
            Preferences.Section(title: "Cropper Style:") {
                CropperStyleSettingView()
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
            Preferences.Section(title: "Colors & Shandow:") {
                GroupBox {
                    HStack {
                        GroupBox {
                            VStack(alignment: .trailing) {
                                WordColorPicker()
                                TransColorPicker()
                                BackgroundColorPicker()
                                RestoreDefaultColors()
                                TextShadowToggle()
                            }
                        }
                        .frame(width: 170)
                        
                        ShadowGroupSettings()
                    }
                }
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
            Preferences.Section(title: "Content Background Display:") {
                ContentBackgroundDisplay()
                VisualEffectGroupSettings()
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

enum CropperStyle: Int {
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
    @AppStorage(FontKey) private var fontData: Data = fontToData(NSFont.systemFont(ofSize: CGFloat(0.0)))!
    
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
            .frame(maxWidth: 230)
            
            Button("Select...") {
                showFontPanel(nil)
            }
        }
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
        HStack {
            Text("\(fontRateKey, specifier: "%.2f")")
            Slider(
                value: $fontRateKey,
                in: 0...1
            )
            .frame(maxWidth: 180)
            
            Stepper(onIncrement: incrementStep, onDecrement: decrementStep) {}
        }
        
        Button("Reset to default: 0.6", action: resetToDefault)
        
        Text("The font rate = fontSizeOfTranslation / fontSizeOfTheWord.")
            .preferenceDescription()
            .frame(width: 340, alignment: .leading)
    }
}

enum ContentStyle: Int {
    case portrait = 0
    case landscape = 1
}

enum PortraitCorner: Int {
    case topLeading = 0
    case topTrailing = 1
}

fileprivate struct ContentStyleSettingView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portrait
    
    @AppStorage(PortraitCornerKey) private var portraitCorner: PortraitCorner = .topLeading
    
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
                        Text("topLeading").tag(PortraitCorner.topLeading)
                        Text("topTrailing").tag(PortraitCorner.topTrailing)
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

fileprivate struct RestoreDefaultColors: View {
    @AppStorage(WordColorKey) private var wordColor: Data = colorToData(NSColor.labelColor.withAlphaComponent(0.3))!
    @AppStorage(TransColorKey) private var transColor: Data = colorToData(NSColor.highlightColor)!
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.clear)!

    var body: some View {
        Button("Use default colors", action: {
            wordColor = colorToData(NSColor.labelColor)!
            transColor = colorToData(NSColor.highlightColor)!
            backgroundColor = colorToData(NSColor.clear)!
        })
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
                    RestoreDefaultShadow()
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

fileprivate let formatter: NumberFormatter = {
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

fileprivate struct RestoreDefaultShadow: View {
    @AppStorage(ShadowColorKey) private var shadowColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(ShadowRadiusKey) private var shadowRadius: Double = 3
    @AppStorage(ShadowXOffSetKey) private var shadowXOffset: Double = 0
    @AppStorage(ShadowYOffSetKey) private var shadowYOffset: Double = 2
    
    var body: some View {
        Button("Use default shadow", action: {
            shadowColor = colorToData(NSColor.labelColor)!
            shadowRadius = 3
            shadowXOffset = 0
            shadowYOffset = 2
        })
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
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreakKey: Bool = true
    
    var body: some View {
        Toggle(isOn: $isAddLineBreakKey, label: {
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

fileprivate struct ContentBackgroundDisplay: View {
    @AppStorage(ContentBackgroundDisplayKey) private var contentBackgroundDisplay: Bool = false
    
    var body: some View {
        Toggle(isOn: $contentBackgroundDisplay, label: {
            Text("Using Visual Effect")
        })
        .toggleStyle(SwitchToggleStyle())
    }
}

fileprivate struct VisualEffectGroupSettings: View {
    @AppStorage(ContentBackgroundDisplayKey) private var contentBackgroundDisplay: Bool = false

    var body: some View {
        if contentBackgroundDisplay {
            GroupBox {
                VStack(alignment: .trailing) {
                    ContentBackGroundVisualEffectMaterial()
                    ContentBackGroundVisualEffectBlendingMode()
                    ContentBackGroundVisualEffectIsEmphasized()
                    ContentBackGroundVisualEffectState()
                }
                .frame(maxWidth: 280)
            }
        }
    }
}

fileprivate struct ContentBackGroundVisualEffectMaterial: View {
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: NSVisualEffectView.Material = .titlebar
    
    let allCases: [(NSVisualEffectView.Material, String)] = [
        (.titlebar, "titlebar"),
        (.selection, "selection"),
        (.menu, "menu"),
        (.popover, "popover"),
        (.sidebar, "sidebar"),
        (.headerView, "headerView"),
        (.sheet, "sheet"),
        (.windowBackground, "windowBackground"),
        (.hudWindow, "hudWindow"),
        (.fullScreenUI, "fullScreenUI"),
        (.toolTip, "toolTip"),
        (.contentBackground, "contentBackground"),
        (.underWindowBackground, "underWindowBackground"),
        (.underPageBackground, "underPageBackground")
    ]
    
    var body: some View {
        HStack {
            Spacer()
            Picker("Material:", selection: $contentBackGroundVisualEffectMaterial) {
                ForEach(allCases, id: \.self.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

fileprivate struct ContentBackGroundVisualEffectBlendingMode: View {
    @AppStorage(ContentBackGroundVisualEffectBlendingModeKey) private var contentBackGroundVisualEffectBlendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    
    let allCases: [(NSVisualEffectView.BlendingMode, String)] = [
        (.behindWindow, "behindWindow"),
        (.withinWindow, "withinWindow")
    ]
    
    var body: some View {
        HStack {
            Spacer()
            Picker("BlengdingMode:", selection: $contentBackGroundVisualEffectBlendingMode) {
                ForEach(allCases, id: \.self.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

fileprivate struct ContentBackGroundVisualEffectIsEmphasized: View {
    @AppStorage(ContentBackGroundVisualEffectIsEmphasizedKey) private var contentBackGroundVisualEffectIsEmphasized: Bool = false
    
    let allCases: [Bool] = [true, false]
    
    var body: some View {
        HStack {
            Spacer()
            Picker("IsEmphasized:", selection: $contentBackGroundVisualEffectIsEmphasized) {
                ForEach(allCases, id: \.self) { option in
                    Text(String(option)).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

fileprivate struct ContentBackGroundVisualEffectState: View {
    @AppStorage(ContentBackGroundVisualEffectStateKey) private var contentBackGroundVisualEffectState: NSVisualEffectView.State = .active
    
    let allCases: [(NSVisualEffectView.State, String)] = [
        (.active, "active"),
        (.inactive, "inactinve"),
        (.followsWindowActiveState, "followsWindowActiveState")
    ]
    
    var body: some View {
        HStack {
            Spacer()
            Picker("EffectState:", selection: $contentBackGroundVisualEffectState) {
                ForEach(allCases, id: \.self.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
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
