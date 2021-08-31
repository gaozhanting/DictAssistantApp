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
    // general and main settings for a slot
    let tRTextRecognitionLevel: Int
    let tRMinimumTextHeight: Double
    let maximumFrameRate: Double
    
    // visual settings for a slot
    let isShowPhrases: Bool
    
    let cropperStyle: CropperStyle

    // -- fine-turning the display of the returned translation text from different dictionaries
    let isDropTitleWord: Bool
    let isAddLineBreak: Bool
    let isAddSpace: Bool
    let isDropFirstTitleWordInTranslation: Bool
    let isJoinTranslationLines: Bool
    
    let isShowWindowShadow: Bool
    
    let isWithAnimation: Bool
    
    // -- content style & max width & max height
    let contentStyle: ContentStyle
    let portraitCorner: PortraitCorner
    // ---- extra
    let portraitMaxHeight: Double
    let landscapeMaxWidth: Double
    
    // -- font size & font rate
    let fontSize: Double
    let fontRate: Double
    
    let theColorScheme: TheColorScheme
    
    // -- color & shadow & background
    // ---- basic three colors
    let wordColor: Data
    let transColor: Data
    let backgroundColor: Data
    // ---- text shadow
    let textShadowToggle: Bool
    let shadowColor: Data
    let shadowRadius: Double
    let shadowXOffSet: Double
    let shadowYOffSet: Double
    // ---- visual effect background
    let contentBackgroundVisualEffect: Bool
    let contentBackGroundVisualEffectMaterial: Int //NSVisualEffectView.Material
    
    // two frames settings for a slot
    let cropperFrame: NSRect
    let contentFrame: NSRect
    
    init(
        tRTextRecognitionLevel: Int,
        tRMinimumTextHeight: Double,
        maximumFrameRate: Double,
        isShowPhrases: Bool,
        cropperStyle: CropperStyle,
        isDropTitleWord: Bool,
        isAddLineBreak: Bool,
        isAddSpace: Bool,
        isDropFirstTitleWordInTranslation: Bool,
        isJoinTranslationLines: Bool,
        isShowWindowShadow: Bool,
        isWithAnimation: Bool,
        contentStyle: ContentStyle,
        portraitCorner: PortraitCorner,
        portraitMaxHeight: Double,
        landscapeMaxWidth: Double,
        fontSize: Double,
        fontRate: Double,
        theColorScheme: TheColorScheme,
        wordColor: Data,
        transColor: Data,
        backgroundColor: Data,
        textShadowToggle: Bool,
        shadowColor: Data,
        shadowRadius: Double,
        shadowXOffSet: Double,
        shadowYOffSet: Double,
        contentBackgroundVisualEffect: Bool,
        contentBackGroundVisualEffectMaterial: Int, //NSVisualEffectView.Material
        cropperFrame: NSRect,
        contentFrame: NSRect
    ) {
        self.tRTextRecognitionLevel = tRTextRecognitionLevel
        self.tRMinimumTextHeight = tRMinimumTextHeight
        self.maximumFrameRate = maximumFrameRate
        self.isShowPhrases = isShowPhrases
        self.cropperStyle = cropperStyle
        self.isDropTitleWord = isDropTitleWord
        self.isAddLineBreak = isAddLineBreak
        self.isAddSpace = isAddSpace
        self.isDropFirstTitleWordInTranslation = isDropFirstTitleWordInTranslation
        self.isJoinTranslationLines = isJoinTranslationLines
        self.isShowWindowShadow = isShowWindowShadow
        self.isWithAnimation = isWithAnimation
        self.contentStyle = contentStyle
        self.portraitCorner = portraitCorner
        self.portraitMaxHeight = portraitMaxHeight
        self.landscapeMaxWidth = landscapeMaxWidth
        self.fontSize = fontSize
        self.fontRate = fontRate
        self.theColorScheme = theColorScheme
        self.wordColor = wordColor
        self.transColor = transColor
        self.backgroundColor = backgroundColor
        self.textShadowToggle = textShadowToggle
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowXOffSet = shadowXOffSet
        self.shadowYOffSet = shadowYOffSet
        self.contentBackgroundVisualEffect = contentBackgroundVisualEffect
        self.contentBackGroundVisualEffectMaterial = contentBackGroundVisualEffectMaterial //NSVisualEffectView.Material
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
    tRTextRecognitionLevel: VNRequestTextRecognitionLevel.fast.rawValue,
    tRMinimumTextHeight: systemDefaultMinimumTextHeight,
    maximumFrameRate: 4,
    isShowPhrases: true,
    cropperStyle: CropperStyle.closed,
    isDropTitleWord: false,
    isAddLineBreak: true,
    isAddSpace: false,
    isDropFirstTitleWordInTranslation: true,
    isJoinTranslationLines: false,
    isShowWindowShadow: true,
    isWithAnimation: true,
    contentStyle: ContentStyle.portrait,
    portraitCorner: PortraitCorner.topTrailing,
    portraitMaxHeight: 200.0,
    landscapeMaxWidth: 260.0,
    fontSize: 18.0,
    fontRate: 0.6,
    theColorScheme: TheColorScheme.system,
    wordColor: colorToData(NSColor.labelColor.withAlphaComponent(0.3))!,
    transColor: colorToData(NSColor.highlightColor)!,
    backgroundColor: colorToData(NSColor.clear)!,
    textShadowToggle: false,
    shadowColor: colorToData(NSColor.labelColor)!,
    shadowRadius: 3,
    shadowXOffSet: 0.0,
    shadowYOffSet: 2.0,
    contentBackgroundVisualEffect: false,
    contentBackGroundVisualEffectMaterial: NSVisualEffectView.Material.titlebar.rawValue,
    cropperFrame: NSRect(x: 100, y: 100, width: 600, height: 200),
    contentFrame: NSRect(x: 300, y: 300, width: 600, height: 200)
)

fileprivate func getCurrentSettings() -> Settings {
    return Settings(
        tRTextRecognitionLevel: UserDefaults.standard.integer(forKey: TRTextRecognitionLevelKey),
        tRMinimumTextHeight: UserDefaults.standard.double(forKey: TRMinimumTextHeightKey),
        maximumFrameRate: UserDefaults.standard.double(forKey: MaximumFrameRateKey),
        isShowPhrases: UserDefaults.standard.bool(forKey: IsShowPhrasesKey),
        cropperStyle: CropperStyle(rawValue: UserDefaults.standard.integer(forKey: CropperStyleKey))!,
        isDropTitleWord: UserDefaults.standard.bool(forKey: IsDropTitleWordKey),
        isAddLineBreak: UserDefaults.standard.bool(forKey: IsAddLineBreakKey),
        isAddSpace: UserDefaults.standard.bool(forKey: IsAddSpaceKey),
        isDropFirstTitleWordInTranslation: UserDefaults.standard.bool(forKey: IsDropFirstTitleWordInTranslationKey),
        isJoinTranslationLines: UserDefaults.standard.bool(forKey: IsJoinTranslationLinesKey),
        isShowWindowShadow: UserDefaults.standard.bool(forKey: IsShowWindowShadowKey),
        isWithAnimation: UserDefaults.standard.bool(forKey: IsWithAnimationKey),
        contentStyle: ContentStyle(rawValue: UserDefaults.standard.integer(forKey: ContentStyleKey))!,
        portraitCorner: PortraitCorner(rawValue: UserDefaults.standard.integer(forKey: PortraitCornerKey))!,
        portraitMaxHeight: UserDefaults.standard.double(forKey: PortraitMaxHeightKey),
        landscapeMaxWidth: UserDefaults.standard.double(forKey: LandscapeMaxWidthKey),
        fontSize: UserDefaults.standard.double(forKey: FontSizeKey),
        fontRate: UserDefaults.standard.double(forKey: FontRateKey),
        theColorScheme: TheColorScheme(rawValue: UserDefaults.standard.string(forKey: TheColorSchemeKey)!)!,
        wordColor: UserDefaults.standard.data(forKey: WordColorKey)!,
        transColor: UserDefaults.standard.data(forKey: TransColorKey)!,
        backgroundColor: UserDefaults.standard.data(forKey: BackgroundColorKey)!,
        textShadowToggle: UserDefaults.standard.bool(forKey: TextShadowToggleKey),
        shadowColor: UserDefaults.standard.data(forKey: ShadowColorKey)!,
        shadowRadius: UserDefaults.standard.double(forKey: ShadowRadiusKey),
        shadowXOffSet: UserDefaults.standard.double(forKey: ShadowXOffSetKey),
        shadowYOffSet: UserDefaults.standard.double(forKey: ShadowYOffSetKey),
        contentBackgroundVisualEffect: UserDefaults.standard.bool(forKey: ContentBackgroundVisualEffectKey),
        contentBackGroundVisualEffectMaterial: UserDefaults.standard.integer(forKey: ContentBackGroundVisualEffectMaterialKey),
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
    @State private var isShowingPopover = false

    var body: some View {
        SlotsSettings()
            .overlay(
                Button(action: { isShowingPopover = true }, label: {
                    Image(systemName: "questionmark").font(.body)
                })
                .clipShape(Circle())
                .padding()
                .shadow(radius: 1)
                .popover(isPresented: $isShowingPopover, arrowEdge: .leading, content: {
                    InfoView()
                })
                ,
                alignment: .bottomTrailing
            )
    }
}

fileprivate struct InfoView: View {
    var body: some View {
        Text("Slot is a collection of all preferences settings (except global shortcut key, font name, is show toast, is show current settings), and cropper window frame, and content window frame. This makes you switch them quickly. You can attach a slot with a text label, by typing text after the icon. You can't switch them when playing. The last gray slot is the immutable default slot.")
            .padding()
            .frame(width: 520, height: 120)
    }
}

fileprivate struct SlotsSettings: View {
    // isShowStoreButton need these almost all @AppStorage data
    @AppStorage(TRTextRecognitionLevelKey) var tRTextRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    @AppStorage(TRMinimumTextHeightKey) var tRMinimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315
    @AppStorage(MaximumFrameRateKey) private var maximumFrameRate: Double = 4

    @AppStorage(IsShowPhrasesKey) var isShowPhrases: Bool = true
    
    @AppStorage(CropperStyleKey) var cropperStyle: CropperStyle = .closed
    
    @AppStorage(IsDropTitleWordKey) private var isDropTitleWord: Bool = false
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    @AppStorage(IsAddSpaceKey) private var isAddSpace: Bool = false
    @AppStorage(IsDropFirstTitleWordInTranslationKey) private var isDropFirstTitleWordInTranslation: Bool = true
    @AppStorage(IsJoinTranslationLinesKey) private var isJoinTranslationLines: Bool = false

    @AppStorage(IsShowWindowShadowKey) private var isShowWindowShadow = false

    @AppStorage(IsWithAnimationKey) var isWithAnimation: Bool = true
    
    @AppStorage(ContentStyleKey) var contentStyle: ContentStyle = .portrait
    @AppStorage(PortraitCornerKey) var portraitCorner: PortraitCorner = .topTrailing
    @AppStorage(PortraitMaxHeightKey) var portraitMaxHeight: Double = 200.0
    @AppStorage(LandscapeMaxWidthKey) var landscapeMaxWidth: Double = 260.0
    
    @AppStorage(FontSizeKey) private var fontSize: Double = 18.0
    @AppStorage(FontRateKey) var fontRate: Double = 0.6
    
    @AppStorage(TheColorSchemeKey) var theColorScheme: TheColorScheme = .system
    
    @AppStorage(WordColorKey) var wordColor: Data = colorToData(NSColor.labelColor.withAlphaComponent(0.3))!
    @AppStorage(TransColorKey) var transColor: Data = colorToData(NSColor.highlightColor)!
    @AppStorage(BackgroundColorKey) var backgroundColor: Data = colorToData(NSColor.clear)!
    
    @AppStorage(TextShadowToggleKey) var textShadowToggle: Bool = false
    @AppStorage(ShadowColorKey) var shadowColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(ShadowRadiusKey) var shadowRadius: Double = 3
    @AppStorage(ShadowXOffSetKey) var shadowXOffSet: Double = 0
    @AppStorage(ShadowYOffSetKey) var shadowYOffSet: Double = 2
    
    @AppStorage(ContentBackgroundVisualEffectKey) var contentBackgroundVisualEffect: Bool = false
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    
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
            s.maximumFrameRate == maximumFrameRate &&
            s.isShowPhrases == isShowPhrases &&
            s.cropperStyle == cropperStyle &&
            s.isDropTitleWord == isDropTitleWord &&
            s.isAddLineBreak == isAddLineBreak &&
            s.isAddSpace == isAddSpace &&
            s.isDropFirstTitleWordInTranslation == isDropFirstTitleWordInTranslation &&
            s.isJoinTranslationLines == isJoinTranslationLines &&
            s.isShowWindowShadow == isShowWindowShadow &&
            s.isWithAnimation == isWithAnimation &&
            s.contentStyle == contentStyle &&
            s.portraitCorner == portraitCorner &&
            s.portraitMaxHeight == portraitMaxHeight &&
            s.landscapeMaxWidth == landscapeMaxWidth &&
            s.fontSize == fontSize &&
            s.fontRate == fontRate &&
            s.theColorScheme == theColorScheme &&
            s.wordColor == wordColor &&
            s.transColor == transColor &&
            s.backgroundColor == backgroundColor &&
            s.textShadowToggle == textShadowToggle &&
            s.shadowColor == shadowColor &&
            s.shadowRadius == shadowRadius &&
            s.shadowXOffSet == shadowXOffSet &&
            s.shadowYOffSet == shadowYOffSet &&
            s.contentBackgroundVisualEffect == contentBackgroundVisualEffect &&
            s.contentBackGroundVisualEffectMaterial == contentBackGroundVisualEffectMaterial && //NSVisualEffectView.Material
            s.cropperFrame == cropperWindow.frame && // crash for SwiftUI Preview, cause there is no cropperWindow; this not react, it is isPlaying switch let it react.
            s.contentFrame == contentWindow.frame
        
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
        maximumFrameRate = s.maximumFrameRate
        isShowPhrases = s.isShowPhrases
        cropperStyle = s.cropperStyle
        isDropTitleWord = s.isDropTitleWord
        isAddLineBreak = s.isAddLineBreak
        isAddSpace = s.isAddSpace
        isDropFirstTitleWordInTranslation = s.isDropFirstTitleWordInTranslation
        isJoinTranslationLines = s.isJoinTranslationLines
        isShowWindowShadow = s.isShowWindowShadow
        isWithAnimation = s.isWithAnimation
        contentStyle = s.contentStyle
        portraitCorner = s.portraitCorner
        portraitMaxHeight = s.portraitMaxHeight
        landscapeMaxWidth = s.landscapeMaxWidth
        fontSize = s.fontSize
        fontRate = s.fontRate
        theColorScheme = s.theColorScheme
        wordColor = s.wordColor
        transColor = s.transColor
        backgroundColor = s.backgroundColor
        textShadowToggle = s.textShadowToggle
        shadowColor = s.shadowColor
        shadowRadius = s.shadowRadius
        shadowXOffSet = s.shadowXOffSet
        shadowYOffSet = s.shadowYOffSet
        contentBackgroundVisualEffect = s.contentBackgroundVisualEffect
        contentBackGroundVisualEffectMaterial = s.contentBackGroundVisualEffectMaterial //NSVisualEffectView.Material
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
        .padding()
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
                    .frame(width: 200)
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

struct SlotsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SlotsSettingsView()
                .environmentObject(StatusData(isPlaying: false))
            
            InfoView()
        }
    }
}
