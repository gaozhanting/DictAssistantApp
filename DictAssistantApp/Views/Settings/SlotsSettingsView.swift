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
    let font: Data
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
        font: Data,
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
        self.font = font
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
    font: fontToData(NSFont.systemFont(ofSize: 18.0))!,
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

fileprivate enum Slot: String, CaseIterable, Identifiable {
    case blue
    case green
    case red

    var id: String { self.rawValue }
}

struct SlotsSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: "Slots:") {
                SlotsSettings()
            }
        }
    }
}

fileprivate struct SlotsSettings: View {
    @AppStorage(SelectedSlotKey) private var selectedSlot = Slot.blue
    @AppStorage(BlueSettingsKey) private var blueSettingsData: Data = settingsToData(defaultSettings)!
    @AppStorage(GreenSettingsKey) private var greenSettingsData: Data = settingsToData(defaultSettings)!
    @AppStorage(RedSettingsKey) private var redSettingsData: Data = settingsToData(defaultSettings)!
    @EnvironmentObject var statusData: StatusData
    
    var isPlaying: Bool {
        statusData.isPlaying
    }
    
    var blueSettings: Settings {
        dataToSettings(blueSettingsData)!
    }
    
    var greenSettings: Settings {
        dataToSettings(greenSettingsData)!
    }
    
    var redSettings: Settings {
        dataToSettings(redSettingsData)!
    }

    func whichSetting(_ slot: Slot) -> Settings {
        switch slot {
        case .blue:
            return blueSettings
        case .green:
            return greenSettings
        case .red:
            return redSettings
        }
    }

    // write settings, read slot
    func selectSlot(_ slot: Slot) {
        let s = whichSetting(slot)
        UserDefaults.standard.set(s.tRTextRecognitionLevel, forKey: TRTextRecognitionLevelKey)
        UserDefaults.standard.set(s.tRMinimumTextHeight, forKey: TRMinimumTextHeightKey)
        UserDefaults.standard.set(s.isWithAnimation, forKey: IsWithAnimationKey)
        UserDefaults.standard.set(s.isShowPhrases, forKey: IsShowPhrasesKey)
        UserDefaults.standard.set(s.isShowCurrentKnown, forKey: IsShowCurrentKnownKey)
        UserDefaults.standard.set(s.cropperStyle.rawValue, forKey: CropperStyleKey)
        UserDefaults.standard.set(s.contentStyle.rawValue, forKey: ContentStyleKey)
        UserDefaults.standard.set(s.isShowWindowShadow, forKey: IsShowWindowShadowKey)
        UserDefaults.standard.set(s.contentBackgroundVisualEffect, forKey: ContentBackgroundVisualEffectKey)
        UserDefaults.standard.set(s.contentBackGroundVisualEffectMaterial, forKey: ContentBackgroundVisualEffectKey)
        UserDefaults.standard.set(s.wordColor, forKey: WordColorKey)
        UserDefaults.standard.set(s.transColor, forKey: TransColorKey)
        UserDefaults.standard.set(s.backgroundColor, forKey: BackgroundColorKey)
        UserDefaults.standard.set(s.portraitCorner.rawValue, forKey: PortraitCornerKey)
        UserDefaults.standard.set(s.showToastToggle, forKey: ShowToastToggleKey)
        UserDefaults.standard.set(s.font, forKey: FontKey)
        UserDefaults.standard.set(s.fontRate, forKey: FontRateKey)
        UserDefaults.standard.set(s.shadowColor, forKey: ShadowColorKey)
        UserDefaults.standard.set(s.shadowRadius, forKey: ShadowRadiusKey)
        UserDefaults.standard.set(s.shadowXOffSet, forKey: ShadowXOffSetKey)
        UserDefaults.standard.set(s.shadowYOffSet, forKey: ShadowYOffSetKey)
        UserDefaults.standard.set(s.textShadowToggle, forKey: TextShadowToggleKey)
        UserDefaults.standard.set(s.portraitMaxHeight, forKey: PortraitMaxHeightKey)
        UserDefaults.standard.set(s.landscapeMaxWidth, forKey: LandscapeMaxWidthKey)
        UserDefaults.standard.set(s.speakWordToggle, forKey: SpeakWordToggleKey)
        UserDefaults.standard.set(s.theColorScheme.rawValue, forKey: TheColorSchemeKey)
        cropperWindow.setFrame(s.cropperFrame, display: true)
        contentWindow.setFrame(s.contentFrame, display: true)
    }
    
    var binding: Binding<Slot> {
        Binding.init(
            get: { selectedSlot },
            set: { newValue in
                selectedSlot = newValue
                selectSlot(selectedSlot)
            }
        )
    }

    var body: some View {
        Picker("", selection: binding) {
            SlotView(color: .blue, selectedSlot: $selectedSlot)
                .tag(Slot.blue)
            
            SlotView(color: .green, selectedSlot: $selectedSlot)
                .tag(Slot.green)
            
            SlotView(color: .red, selectedSlot: $selectedSlot)
                .tag(Slot.red)
        }
        .labelsHidden()
        .pickerStyle(RadioGroupPickerStyle())
        .disabled(isPlaying)
    }
}

fileprivate struct SlotView: View {
    @AppStorage(BlueLabelKey) private var blueLabel: String = ""
    @AppStorage(GreenLabelKey) private var greenLabel: String = ""
    @AppStorage(RedLabelKey) private var redLabel: String = ""
    @AppStorage(BlueSettingsKey) private var blueSettingsData: Data = settingsToData(defaultSettings)!
    @AppStorage(GreenSettingsKey) private var greenSettingsData: Data = settingsToData(defaultSettings)!
    @AppStorage(RedSettingsKey) private var redSettingsData: Data = settingsToData(defaultSettings)!
    
    var blueSettings: Settings {
        dataToSettings(blueSettingsData)!
    }
    
    var greenSettings: Settings {
        dataToSettings(greenSettingsData)!
    }
    
    var redSettings: Settings {
        dataToSettings(redSettingsData)!
    }
    
    func whichSetting(_ slot: Slot) -> Settings {
        switch slot {
        case .blue:
            return blueSettings
        case .green:
            return greenSettings
        case .red:
            return redSettings
        }
    }
    
    let color: Color
    @Binding var selectedSlot: Slot
    
    // write slot, read settings
    func storeSlot(_ slot: Slot) {
        let currentSettings = Settings(
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
            font: UserDefaults.standard.data(forKey: FontKey)!,
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
        
        switch selectedSlot {
        case .blue:
            blueSettingsData = settingsToData(currentSettings)!
        case .green:
            greenSettingsData = settingsToData(currentSettings)!
        case .red:
            redSettingsData = settingsToData(currentSettings)!
        }
    }
    
    var isColorSelected: Bool {
        if color == .blue {
            return selectedSlot.rawValue == "blue"
        }
        if color == .green {
            return selectedSlot.rawValue == "green"
        }
        if color == .red {
            return selectedSlot.rawValue == "red"
        }
        return false // not this case
    }
    
    @AppStorage(TRTextRecognitionLevelKey) private var tRTextRecognitionLevel: VNRequestTextRecognitionLevel = .fast // fast 1, accurate 0
    @AppStorage(TRMinimumTextHeightKey) private var tRMinimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315
    @AppStorage(IsWithAnimationKey) private var isWithAnimation: Bool = true
    @AppStorage(IsShowPhrasesKey) private var isShowPhrases: Bool = true
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    @AppStorage(CropperStyleKey) private var cropperStyle: CropperStyle = .closed
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portrait
    @AppStorage(IsShowWindowShadowKey) private var isShowWindowShadow = false
    @AppStorage(ContentBackgroundVisualEffectKey) private var contentBackgroundVisualEffect: Bool = false
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    @AppStorage(WordColorKey) private var wordColor: Data = colorToData(NSColor.labelColor.withAlphaComponent(0.3))!
    @AppStorage(TransColorKey) private var transColor: Data = colorToData(NSColor.highlightColor)!
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.clear)!
    @AppStorage(PortraitCornerKey) private var portraitCorner: PortraitCorner = .topLeading
    @AppStorage(ShowToastToggleKey) private var showToastToggle: Bool = true
    @AppStorage(FontKey) private var fontData: Data = fontToData(NSFont.systemFont(ofSize: 18.0))!
    @AppStorage(FontRateKey) private var fontRate: Double = 0.6
    @AppStorage(ShadowColorKey) private var shadowColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(ShadowRadiusKey) private var shadowRadius: Double = 3
    @AppStorage(ShadowXOffSetKey) private var shadowXOffSet: Double = 0
    @AppStorage(ShadowYOffSetKey) private var shadowYOffSet: Double = 2
    @AppStorage(TextShadowToggleKey) private var textShadowToggle: Bool = false
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 200.0
    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 260.0
    @AppStorage(SpeakWordToggleKey) private var speakWordToggle: Bool = false
    @AppStorage(TheColorSchemeKey) private var theColorScheme: TheColorScheme = .system

    var isTheSame: Bool {
        let s = whichSetting(selectedSlot)
        return s.tRTextRecognitionLevel == tRTextRecognitionLevel.rawValue &&
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
            s.font == fontData &&
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
    }
   
    func whichLabel(_ color: Color) -> Binding<String> {
        switch color {
        case .blue:
            return $blueLabel
        case .green:
            return $greenLabel
        case .red:
            return $redLabel
        default: // not this case
            return $blueLabel
        }
    }
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "cube.fill")
                    .font(.title)
                    .foregroundColor(color)
                
                TextField("", text: whichLabel(color))
                    .frame(width: 70)
            }
            
            if isColorSelected && !isTheSame {
                Button("store", action: {
                    storeSlot(selectedSlot)
                })
            }
        }
    }
}

struct SlotsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SlotsSettingsView()
            .environmentObject(StatusData(isPlaying: false))
    }
}
