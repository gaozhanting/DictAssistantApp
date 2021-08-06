//
//  SlotsSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/8/6.
//

import SwiftUI
import Preferences

struct SlotsSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: "Slots:") {
                SlotsSettings()
            }
        }
    }
}

fileprivate enum Slot: String, CaseIterable, Identifiable {
    case blue
    case green
    case red
//    case yellow
//    case orange
    
    var id: String { self.rawValue }
}

// write slot, read settings
fileprivate func updateSlot(_ slot: Slot) {
    slots[slot] = Settings(
        tRTextRecognitionLevel: UserDefaults.standard.integer(forKey: TRTextRecognitionLevelKey),
        tRMinimumTextHeight: UserDefaults.standard.double(forKey: TRMinimumTextHeightKey),
        isWithAnimation: UserDefaults.standard.bool(forKey: IsWithAnimationKey),
        isShowPhrases: UserDefaults.standard.bool(forKey: IsShowPhrasesKey),
        isShowCurrentKnown: UserDefaults.standard.bool(forKey: IsShowCurrentKnownKey),
        cropperStyle: CropperStyle(rawValue: UserDefaults.standard.integer(forKey: CropperStyleKey))!,
        contentStyle: ContentStyle(rawValue: UserDefaults.standard.integer(forKey: ContentStyleKey))!,
        isShowWindowShadow: UserDefaults.standard.bool(forKey: IsShowWindowShadowKey),
        contentBackgroundVisualEffect: UserDefaults.standard.bool(forKey: ContentBackgroundVisualEffectKey),
        contentBackGroundVisualEffectMaterial: NSVisualEffectView.Material(rawValue: UserDefaults.standard.integer(forKey: ContentBackGroundVisualEffectMaterialKey))!,
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
}

// write settings, read slot
fileprivate func selectSlot(_ slot: Slot) {
    let s = slots[slot]!
    UserDefaults.standard.set(s.tRTextRecognitionLevel, forKey: TRTextRecognitionLevelKey)
    UserDefaults.standard.set(s.tRMinimumTextHeight, forKey: TRMinimumTextHeightKey)
    UserDefaults.standard.set(s.isWithAnimation, forKey: IsWithAnimationKey)
    UserDefaults.standard.set(s.isShowPhrases, forKey: IsShowPhrasesKey)
    UserDefaults.standard.set(s.isShowCurrentKnown, forKey: IsShowCurrentKnownKey)
    UserDefaults.standard.set(s.cropperStyle.rawValue, forKey: CropperStyleKey)
    UserDefaults.standard.set(s.contentStyle.rawValue, forKey: ContentStyleKey)
    UserDefaults.standard.set(s.isShowWindowShadow, forKey: IsShowWindowShadowKey)
    UserDefaults.standard.set(s.contentBackgroundVisualEffect, forKey: ContentBackgroundVisualEffectKey)
    UserDefaults.standard.set(s.contentBackGroundVisualEffectMaterial.rawValue, forKey: ContentBackgroundVisualEffectKey)
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

struct Settings {
    let tRTextRecognitionLevel: Int
    let tRMinimumTextHeight: Double
    let isWithAnimation: Bool
    let isShowPhrases: Bool
    let isShowCurrentKnown: Bool
    let cropperStyle: CropperStyle
    let contentStyle: ContentStyle
    let isShowWindowShadow: Bool
    let contentBackgroundVisualEffect: Bool
    let contentBackGroundVisualEffectMaterial: NSVisualEffectView.Material
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
        contentBackGroundVisualEffectMaterial: NSVisualEffectView.Material,
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
    contentBackGroundVisualEffectMaterial: .hudWindow,
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

// stored this data in UserDefaults (a file ??)
fileprivate var blueSettings = defaultSettings
fileprivate var greenSettings = defaultSettings
fileprivate var redSettings = defaultSettings

fileprivate var slots: [Slot: Settings] = [
    .blue: blueSettings,
    .green: greenSettings,
    .red: redSettings
]

fileprivate struct SlotsSettings: View {
    @AppStorage(SelectedSlotKey) private var selectedSlot = Slot.blue
    
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
    }
}

fileprivate struct SlotView: View {
    let color: Color
    @Binding var selectedSlot: Slot
    
    var body: some View {
        HStack {
            Image(systemName: "cube.fill")
                .font(.largeTitle)
                .foregroundColor(color)
            
            Button("store", action: {
                updateSlot(selectedSlot)
            })
//            .disabled(true)
        }
    }
}

struct SlotsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SlotsSettingsView()
    }
}
