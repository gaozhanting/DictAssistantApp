//
//  SlotsSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/8/6.
//

import SwiftUI
import Preferences
import Vision

fileprivate struct Settings: Codable {
    let tRTextRecognitionLevel: Int
    let tRMinimumTextHeight: Double
    let isWithAnimation: Bool
    let isShowPhrases: Bool
    let isShowCurrentKnown: Bool
    let cropperStyle: CropperStyle
    let contentStyle: ContentStyle
    let isShowWindowShadow: Bool
    let contentBackgroundVisualEffect: Bool
    let contentBackGroundVisualEffectMaterial: Int //NSVisualEffectView.Material
    let wordColor: Data
    let transColor: Data
    let backgroundColor: Data
    let portraitCorner: PortraitCorner
    let showToastToggle: Bool
    let fontData: Data
    let fontRate: Double
    let shadowColor: Data
    let shadowRadius: Double
    let shadowXOffSet: Double
    let shadowYOffSet: Double
    let textShadowToggle: Bool
    let portraitMaxHeight: Double
    let landscapeMaxWidth: Double
    let speakWordToggle: Bool
    let theColorScheme: TheColorScheme
    
    let cropperFrame: NSRect
    let contentFrame: NSRect
    
    init(
        tRTextRecognitionLevel: Int,
        tRMinimumTextHeight: Double,
        isWithAnimation: Bool,
        isShowPhrases: Bool,
        isShowCurrentKnown: Bool,
        cropperStyle: CropperStyle,
        contentStyle: ContentStyle,
        isShowWindowShadow: Bool,
        contentBackgroundVisualEffect: Bool,
        contentBackGroundVisualEffectMaterial: Int, // NSVisualEffectView.Material,
        wordColor: Data,
        transColor: Data,
        backgroundColor: Data,
        portraitCorner: PortraitCorner,
        showToastToggle: Bool,
        fontData: Data,
        fontRate: Double,
        shadowColor: Data,
        shadowRadius: Double,
        shadowXOffSet: Double,
        shadowYOffSet: Double,
        textShadowToggle: Bool,
        portraitMaxHeight: Double,
        landscapeMaxWidth: Double,
        speakWordToggle: Bool,
        theColorScheme: TheColorScheme,
        cropperFrame: NSRect,
        contentFrame: NSRect
    ) {
        self.tRTextRecognitionLevel = tRTextRecognitionLevel
        self.tRMinimumTextHeight = tRMinimumTextHeight
        self.isWithAnimation = isWithAnimation
        self.isShowPhrases = isShowPhrases
        self.isShowCurrentKnown = isShowCurrentKnown
        self.cropperStyle = cropperStyle
        self.contentStyle = contentStyle
        self.isShowWindowShadow = isShowWindowShadow
        self.contentBackgroundVisualEffect = contentBackgroundVisualEffect
        self.contentBackGroundVisualEffectMaterial = contentBackGroundVisualEffectMaterial
        self.wordColor = wordColor
        self.transColor = transColor
        self.backgroundColor = backgroundColor
        self.portraitCorner = portraitCorner
        self.showToastToggle = showToastToggle
        self.fontData = fontData
        self.fontRate = fontRate
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowXOffSet = shadowXOffSet
        self.shadowYOffSet = shadowYOffSet
        self.textShadowToggle = textShadowToggle
        self.portraitMaxHeight = portraitMaxHeight
        self.landscapeMaxWidth = landscapeMaxWidth
        self.speakWordToggle = speakWordToggle
        self.theColorScheme = theColorScheme
        self.cropperFrame = cropperFrame
        self.contentFrame = contentFrame
    }
}

fileprivate func settingsToData(_ settings: Settings) -> Data? {
    let data = try? PropertyListEncoder.init().encode(settings)
    return data
}

fileprivate func dataToSettings(_ data: Data) -> Settings? {
    let settings = try? PropertyListDecoder.init().decode(Settings.self, from: data)
    return settings
}

fileprivate let defaultSettings = Settings(
    tRTextRecognitionLevel: 1,
    tRMinimumTextHeight: systemDefaultMinimumTextHeight,
    isWithAnimation: true,
    isShowPhrases: true,
    isShowCurrentKnown: false,
    cropperStyle: .closed,
    contentStyle: .portrait,
    isShowWindowShadow: true,
    contentBackgroundVisualEffect: false,
    contentBackGroundVisualEffectMaterial: NSVisualEffectView.Material.hudWindow.rawValue,
    wordColor: colorToData(NSColor.labelColor.withAlphaComponent(0.3))!,
    transColor: colorToData(NSColor.highlightColor)!,
    backgroundColor: colorToData(NSColor.clear)!,
    portraitCorner: .topLeading,
    showToastToggle: true,
    fontData: fontToData(NSFont.systemFont(ofSize: 18.0))!,
    fontRate: 0.6,
    shadowColor: colorToData(NSColor.labelColor)!,
    shadowRadius: 3,
    shadowXOffSet: 0,
    shadowYOffSet: 2,
    textShadowToggle: false,
    portraitMaxHeight: 200.0,
    landscapeMaxWidth: 260.0,
    speakWordToggle: false,
    theColorScheme: .system,
    cropperFrame: NSRect(x: 100, y: 100, width: 600, height: 200),
    contentFrame: NSRect(x: 300, y: 300, width: 600, height: 200)
)

fileprivate func getCurrentSettings() -> Settings {
    return Settings(
        tRTextRecognitionLevel: UserDefaults.standard.integer(forKey: TRTextRecognitionLevelKey),
        tRMinimumTextHeight: UserDefaults.standard.double(forKey: TRMinimumTextHeightKey),
        isWithAnimation: UserDefaults.standard.bool(forKey: IsWithAnimationKey),
        isShowPhrases: UserDefaults.standard.bool(forKey: IsShowPhrasesKey),
        isShowCurrentKnown: UserDefaults.standard.bool(forKey: IsShowCurrentKnownKey),
        cropperStyle: CropperStyle(rawValue: UserDefaults.standard.integer(forKey: CropperStyleKey))!,
        contentStyle: ContentStyle(rawValue: UserDefaults.standard.integer(forKey: ContentStyleKey))!,
        isShowWindowShadow: UserDefaults.standard.bool(forKey: IsShowWindowShadowKey),
        contentBackgroundVisualEffect: UserDefaults.standard.bool(forKey: ContentBackgroundVisualEffectKey),
        contentBackGroundVisualEffectMaterial: UserDefaults.standard.integer(forKey: ContentBackGroundVisualEffectMaterialKey),
        wordColor: UserDefaults.standard.data(forKey: WordColorKey)!,
        transColor: UserDefaults.standard.data(forKey: TransColorKey)!,
        backgroundColor: UserDefaults.standard.data(forKey: BackgroundColorKey)!,
        portraitCorner: PortraitCorner(rawValue: UserDefaults.standard.integer(forKey: PortraitCornerKey))!,
        showToastToggle: UserDefaults.standard.bool(forKey: ShowToastToggleKey),
        fontData: UserDefaults.standard.data(forKey: FontKey)!,
        fontRate: UserDefaults.standard.double(forKey: FontRateKey),
        shadowColor: UserDefaults.standard.data(forKey: ShadowColorKey)!,
        shadowRadius: UserDefaults.standard.double(forKey: ShadowRadiusKey),
        shadowXOffSet: UserDefaults.standard.double(forKey: ShadowXOffSetKey),
        shadowYOffSet: UserDefaults.standard.double(forKey: ShadowYOffSetKey),
        textShadowToggle: UserDefaults.standard.bool(forKey: TextShadowToggleKey),
        portraitMaxHeight: UserDefaults.standard.double(forKey: PortraitMaxHeightKey),
        landscapeMaxWidth: UserDefaults.standard.double(forKey: LandscapeMaxWidthKey),
        speakWordToggle: UserDefaults.standard.bool(forKey: SpeakWordToggleKey),
        theColorScheme: TheColorScheme(rawValue: UserDefaults.standard.string(forKey: TheColorSchemeKey)!)!,
        cropperFrame: cropperWindow.frame,
        contentFrame: contentWindow.frame
    )
}

fileprivate enum Slot: String, CaseIterable, Identifiable {
    case blue
    case purple
    case pink
    case red
    case orange
    case yellow
    case green
    case gray

    var id: String { self.rawValue }
}

fileprivate func theColor(from slot: Slot) -> Color {
    switch slot {
    case .blue: return Color.blue
    case .purple: return Color.purple
    case .pink: return Color.pink
    case .red: return Color.red
    case .orange: return Color.orange
    case .yellow: return Color.yellow
    case .green: return Color.green
    case .gray: return Color.gray
    }
}

struct SlotsSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: "Slots:") {
                SlotsSettings()
            }
            Preferences.Section(title: "Info:") {
                Info()
            }
        }
    }
}

fileprivate struct SlotsSettings: View {
    // isShowStoreButton need these almost all @AppStorage data
    @AppStorage(TRTextRecognitionLevelKey) var tRTextRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    @AppStorage(TRMinimumTextHeightKey) var tRMinimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315
    @AppStorage(IsWithAnimationKey) var isWithAnimation: Bool = true
    @AppStorage(IsShowPhrasesKey) var isShowPhrases: Bool = true
    @AppStorage(IsShowCurrentKnownKey) var isShowCurrentKnown: Bool = false
    @AppStorage(CropperStyleKey) var cropperStyle: CropperStyle = .closed
    @AppStorage(ContentStyleKey) var contentStyle: ContentStyle = .portrait
    @AppStorage(IsShowWindowShadowKey) var isShowWindowShadow = false
    @AppStorage(ContentBackgroundVisualEffectKey) var contentBackgroundVisualEffect: Bool = false
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    @AppStorage(WordColorKey) var wordColor: Data = colorToData(NSColor.labelColor.withAlphaComponent(0.3))!
    @AppStorage(TransColorKey) var transColor: Data = colorToData(NSColor.highlightColor)!
    @AppStorage(BackgroundColorKey) var backgroundColor: Data = colorToData(NSColor.clear)!
    @AppStorage(PortraitCornerKey) var portraitCorner: PortraitCorner = .topLeading
    @AppStorage(ShowToastToggleKey) var showToastToggle: Bool = true
    @AppStorage(FontKey) var fontData: Data = fontToData(NSFont.systemFont(ofSize: 18.0))!
    @AppStorage(FontRateKey) var fontRate: Double = 0.6
    @AppStorage(ShadowColorKey) var shadowColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(ShadowRadiusKey) var shadowRadius: Double = 3
    @AppStorage(ShadowXOffSetKey) var shadowXOffSet: Double = 0
    @AppStorage(ShadowYOffSetKey) var shadowYOffSet: Double = 2
    @AppStorage(TextShadowToggleKey) var textShadowToggle: Bool = false
    @AppStorage(PortraitMaxHeightKey) var portraitMaxHeight: Double = 200.0
    @AppStorage(LandscapeMaxWidthKey) var landscapeMaxWidth: Double = 260.0
    @AppStorage(SpeakWordToggleKey) var speakWordToggle: Bool = false
    @AppStorage(TheColorSchemeKey) var theColorScheme: TheColorScheme = .system
    
    @EnvironmentObject var statusData: StatusData
    var isPlaying: Bool {
        statusData.isPlaying
    }
    
    @AppStorage(SelectedSlotKey) private var selectedSlot = Slot.blue
    
    @AppStorage(BlueLabelKey) var blueLabel: String = ""
    @AppStorage(PurpleLabelKey) var purpleLabel: String = ""
    @AppStorage(PinkLabelKey) var pinkLabel: String = ""
    @AppStorage(RedLabelKey) var redLabel: String = ""
    @AppStorage(OrangeLabelKey) var orangeLabel: String = ""
    @AppStorage(YellowLabelKey) var yellowLabel: String = ""
    @AppStorage(GreenLabelKey) var greenLabel: String = ""
    @AppStorage(GrayLabelKey) var grayLabel: String = "Default"
    
    @AppStorage(BlueSettingsKey) var blueSettingsData: Data = settingsToData(defaultSettings)!
    @AppStorage(PurpleSettingsKey) var purpleSettingsData: Data = settingsToData(defaultSettings)!
    @AppStorage(PinkSettingsKey) var pinkSettingsData: Data = settingsToData(defaultSettings)!
    @AppStorage(RedSettingsKey) var redSettingsData: Data = settingsToData(defaultSettings)!
    @AppStorage(OrangeSettingsKey) var orangeSettingsData: Data = settingsToData(defaultSettings)!
    @AppStorage(YellowSettingsKey) var yellowSettingsData: Data = settingsToData(defaultSettings)!
    @AppStorage(GreenSettingsKey) var greenSettingsData: Data = settingsToData(defaultSettings)!
    @AppStorage(GraySettingsKey) var graySettingsData: Data = settingsToData(defaultSettings)!
        
    var selectedSettings: Settings {
        switch selectedSlot {
        case .blue: return dataToSettings(blueSettingsData)!
        case .purple: return dataToSettings(purpleSettingsData)!
        case .pink: return dataToSettings(pinkSettingsData)!
        case .red: return dataToSettings(redSettingsData)!
        case .orange: return dataToSettings(orangeSettingsData)!
        case .yellow: return dataToSettings(yellowSettingsData)!
        case .green: return dataToSettings(greenSettingsData)!
        case .gray: return dataToSettings(graySettingsData)!
        }
    }
    
    // write slot, read settings
    func storeSlot(_ slot: Slot) -> () -> Void {
        return {
            let currentSettings = getCurrentSettings()
            switch slot {
            case .blue: blueSettingsData = settingsToData(currentSettings)!
            case .purple: purpleSettingsData = settingsToData(currentSettings)!
            case .pink: pinkSettingsData = settingsToData(currentSettings)!
            case .red: redSettingsData = settingsToData(currentSettings)!
            case .orange: orangeSettingsData = settingsToData(currentSettings)!
            case .yellow: yellowSettingsData = settingsToData(currentSettings)!
            case .green: greenSettingsData = settingsToData(currentSettings)!
            case .gray: print("gray do nothing")
            }
        }
    }

    func isSelectedSlotEqualWithCurrentSettings() -> Bool {
        let s = selectedSettings
        let result = s.tRTextRecognitionLevel == tRTextRecognitionLevel &&
            s.tRMinimumTextHeight == tRMinimumTextHeight &&
            s.isWithAnimation == isWithAnimation &&
            s.isShowPhrases == isShowPhrases &&
            s.isShowCurrentKnown == isShowCurrentKnown &&
            s.cropperStyle == cropperStyle &&
            s.contentStyle == contentStyle &&
            s.isShowWindowShadow == isShowWindowShadow &&
            s.contentBackgroundVisualEffect == contentBackgroundVisualEffect &&
            s.contentBackGroundVisualEffectMaterial == contentBackGroundVisualEffectMaterial &&
            s.wordColor == wordColor &&
            s.transColor == transColor &&
            s.backgroundColor == backgroundColor &&
            s.portraitCorner == portraitCorner &&
            s.showToastToggle == showToastToggle &&
            s.fontData == fontData &&
            s.fontRate == fontRate &&
            s.shadowColor == shadowColor &&
            s.shadowRadius == shadowRadius &&
            s.shadowXOffSet == shadowXOffSet &&
            s.shadowYOffSet == shadowYOffSet &&
            s.textShadowToggle == textShadowToggle &&
            s.portraitMaxHeight == portraitMaxHeight &&
            s.landscapeMaxWidth == landscapeMaxWidth &&
            s.speakWordToggle == speakWordToggle &&
            s.theColorScheme == theColorScheme
//            s.cropperFrame == cropperWindow.frame && // crash for SwiftUI Preview, cause there is no cropperWindow
//            s.contentFrame == contentWindow.frame
        
        return result
    }
    
    func isShowStoreButton(_ slot: Slot) -> Bool {
        slot != .gray &&
            selectedSlot == slot &&
            !isSelectedSlotEqualWithCurrentSettings()
    }
    
    // write settings, read slot
    fileprivate func dumpSettings(from s: Settings) {
        tRTextRecognitionLevel = s.tRTextRecognitionLevel
        tRMinimumTextHeight = s.tRMinimumTextHeight
        isWithAnimation = s.isWithAnimation
        isShowPhrases = s.isShowPhrases
        isShowCurrentKnown = s.isShowCurrentKnown
        cropperStyle = s.cropperStyle
        contentStyle = s.contentStyle
        isShowWindowShadow = s.isShowWindowShadow
        contentBackgroundVisualEffect = s.contentBackgroundVisualEffect
        contentBackGroundVisualEffectMaterial = s.contentBackGroundVisualEffectMaterial
        wordColor = s.wordColor
        transColor = s.transColor
        backgroundColor = s.backgroundColor
        portraitCorner = s.portraitCorner
        showToastToggle = s.showToastToggle
        fontData = s.fontData
        fontRate = s.fontRate
        shadowColor = s.shadowColor
        shadowRadius = s.shadowRadius
        shadowXOffSet = s.shadowXOffSet
        shadowYOffSet = s.shadowYOffSet
        textShadowToggle = s.textShadowToggle
        portraitMaxHeight = s.portraitMaxHeight
        landscapeMaxWidth = s.landscapeMaxWidth
        speakWordToggle = s.speakWordToggle
        theColorScheme = s.theColorScheme
        cropperWindow.setFrame(s.cropperFrame, display: true)
        contentWindow.setFrame(s.contentFrame, display: true)
    }
    
    var binding: Binding<Slot> {
        Binding.init(
            get: { selectedSlot },
            set: { newValue in
                selectedSlot = newValue
                dumpSettings(from: selectedSettings)
            }
        )
    }
    
    func getTheLabel(_ slot: Slot) -> Binding<String> {
        switch slot {
        case .blue: return $blueLabel
        case .purple: return $purpleLabel
        case .pink: return $pinkLabel
        case .red: return $redLabel
        case .orange: return $orangeLabel
        case .yellow: return $yellowLabel
        case .green: return $greenLabel
        case .gray: return $grayLabel
        }
    }
    
    var body: some View {
        Picker("", selection: binding) {
            ForEach(Slot.allCases) { color in
                SlotItem(
                    color: theColor(from: color),
                    label: getTheLabel(color),
                    isShowStoreButton: isShowStoreButton(color),
                    storeAction: storeSlot(color)
                )
                .tag(color)
            }
        }
        .labelsHidden()
        .pickerStyle(RadioGroupPickerStyle())
        .disabled(isPlaying)
    }
}

fileprivate struct SlotItem: View {
    let color: Color
    @Binding var label: String
    let isShowStoreButton: Bool
    let storeAction: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "cube.fill")
                    .font(.title)
                    .foregroundColor(color)
                
                TextField("", text: $label)
                    .font(.callout)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(width: 150)
                    .disabled(color == Color.gray)
            }
            
            if isShowStoreButton {
                Button("store", action: {
                    storeAction()
                })
            }
        }
    }
}

fileprivate struct Info: View {
    var body: some View {
        Text("Slot is a collection of all preferences settings (except global shortcut key settings) & cropper window frame & content window frame. This makes you switch them quickly. You can't switch them when playing. The last gray slot is the immutable default slot.")
            .font(.callout)
            .frame(width: 460, height: 100)
    }
}

struct SlotsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SlotsSettingsView()
                .environmentObject(StatusData(isPlaying: false))
            
            Info()
        }
    }
}
