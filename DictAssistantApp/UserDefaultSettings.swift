//
//  UserDefaultSettings.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import Foundation
import Cocoa
import Vision
import Combine

// UserDefault keys:
let IsFinishedOnboardingKey = "IsFinishedOnboardingKey"

let RemoteDictURLStringKey = "RemoteDictURLStringKey"

let defaultFontName = NSFont.systemFont(ofSize: 0).fontName // returns ".AppleSystemUIFont"
let defaultNSFont = NSFont(name: defaultFontName, size: 14.0)!
// -- these not in slots
let FontNameKey = "FontNameKey" // not in slot for basic consistence of visual

// General
let IsShowKnownKey = "IsShowKnownKey" // not in slot for its core function
let IsShowKnownButWithOpacity0Key = "IsShowKnownButWithOpacity0Key"
let IsConcealTranslationKey = "IsConcealTranslationKey"
let IsShowNotFoundKey = "IsShowNotFoundKey"

let IsShowToastKey = "IsShowToastKey" // not in slot for basic consistence of an auxiliary extra trick

// Recording
let CropperStyleKey = "CropperStyleKey"
let CropperStyleDefault = CropperStyle.strokeBorder.rawValue

let HighlightModeKey = "HighlightModeKey"
let HighlightModeDefault = HighlightMode.rectangle.rawValue

let HLRectangleColorKey = "HLRectangleColorKey"
let HLRectangleColorDefault = colorToData(NSColor.magenta.shadow(withLevel: 0.3)!.withAlphaComponent(0.3))!

let StrokeDownwardOffsetKey = "StrokeDownwardOffsetKey"
let HLDottedColorKey = "HLDottedColorKey"
let StrokeLineWidthKey = "StrokeLineWidthKey"
let StrokeDashPaintedKey = "StrokeDashPaintedKey"
let StrokeDashUnPaintedKey = "StrokeDashUnPaintedKey"

let IsShowIndexKey = "IsShowIndexKey"
let IndexColorKey = "IndexColorKey"
let ContentIndexColorKey = "ContentIndexColorKey"
let IndexBgColorKey = "IndexBgColorKey"
let IndexPaddingKey = "IndexPaddingKey"
let IndexXBasicKey = "IndexXBasicKey"
let IndexFontSizeKey = "IndexFontSizeKey"

let IsAlwaysRefreshHighlightKey = "IsAlwaysRefreshHighlightKey"

let MaximumFrameRateKey = "MaximumFrameRateKey"

// Vision
let RecognitionLevelKey = "RecognitionLevelKey"
let MinimumTextHeightKey = "MinimumTextHeightKey"

// NLP
let IsOpenLemmaKey = "IsOpenLemmaKey"
let DoNameRecognitionKey = "DoNameRecognitionKey"
let DoPhraseDetectionKey = "DoPhraseDetectionKey"

// Dictionary
let UseAppleDictModeKey = "UseAppleDictModeKey"
let UseEntryModeKey = "UseEntryModeKey"

// Content
let IsDropTitleWordKey = "IsDropTitleWordKey"
let IsAddLineBreakKey = "IsAddLineBreakKey"
let IsAddSpaceKey = "IsAddSpaceKey"
let IsDropFirstTitleWordInTranslationKey = "IsDropFirstTitleWordInTranslationKey"
let IsJoinTranslationLinesKey = "IsJoinTranslationLinesKey"
let ChineseCharacterConvertModeKey = "ChineseCharacterConvertModeKey"

// Appearance
let PortraitCornerKey = "PortraitCornerKey"
let PortraitMaxHeightKey = "PortraitMaxHeightKey"
let LandscapeStyleKey = "LandscapeStyleKey"
let LandscapeMaxWidthKey = "LandscapeMaxWidthKey"

let FontSizeKey = "FontSizeKey"
let LineSpacingKey = "LineSpacingKey"
let FontRatioKey = "FontRatioKey"

let WordColorKey = "WordColorKey"
let TransColorKey = "TransColorKey"
let BackgroundColorKey = "BackgroundColorKey"
let BackgroundColorDefault = colorToData(NSColor.textBackgroundColor)!

let UseContentBackgroundVisualEffectKey = "UseContentBackgroundVisualEffectKey"
let ContentBackGroundVisualEffectMaterialKey = "ContentBackGroundVisualEffectMaterialKey"

let TheColorSchemeKey = "TheColorSchemeKey"

let ContentPaddingStyleKey = "ContentPaddingStyleKey"
// standard
let StandardCornerRadiusKey = "StandardCornerRadiusKey"
// minimalist
let MinimalistVPaddingKey = "MinimalistVPaddingKey"
let MinimalistHPaddingKey = "MinimalistHPaddingKey"

let IsWithAnimationKey = "IsWithAnimationKey"

// Enums
enum ContentPaddingStyle: Int, Codable {
    case standard
    case minimalist
}

enum HighlightMode: Int, Codable {
    case dotted
    case rectangle
    case disabled
}

enum IndexXBasic: Int, Codable {
    case leading
    case center
    case trailing
}

enum CropperStyle: Int, Codable {
    case empty = 0
    case rectangle = 1
    case strokeBorder = 2
    
    case leadingBorder = 3
    case trailingBorder = 4
    case topBorder = 5
    case bottomBorder = 6
}

enum TitleWord: Int, Codable {
    case primitive = 0
    case lemma = 1
}

enum UseAppleDictMode: Int, Codable {
    case notUse = 0
    case afterBuiltIn = 1 // default
    case beforeBuiltIn = 2
    case only = 3
}

enum UseEntryMode: Int, Codable {
    case notUse = 0
    case asFirstPriority = 1
    case asLastPriority = 2
    case only = 3
}

enum ChineseCharacterConvertMode: Int, Codable {
    case notConvert = 0
    case convertToTraditional = 1
    case convertToSimplified = 2
}

enum ContentLayout: Int, Codable {
    case portrait = 0
    case landscape = 1
}

enum PortraitCorner: Int, Codable {
    case topTrailing = 0
    case topLeading = 1
    case bottom = 2 // bottom
    case top = 3 // top
}

enum LandscapeStyle: Int, Codable {
    case normal = 0 // lead
    case autoScrolling = 1 // trailing
    case centered = 2 // center
}

enum TheColorScheme: Int, Codable {
    case light = 0
    case dark = 1
    case system = 2
    case systemReversed = 3
}

// in slot defaults
// !! Need sync with var defaultSettings in SlotsSettingsView
private let scenarioKV: [String: Any] = [
    PortraitCornerKey: PortraitCorner.top.rawValue,
    PortraitMaxHeightKey: 100.0,
    LandscapeStyleKey: LandscapeStyle.normal.rawValue,
    LandscapeMaxWidthKey: 160.0,
    
    ContentPaddingStyleKey: ContentPaddingStyle.standard.rawValue,
    StandardCornerRadiusKey: 6.0,
    MinimalistVPaddingKey: 2.0,
    MinimalistHPaddingKey: 6.0,
    
    FontSizeKey: 14,
    LineSpacingKey: 2.0,
    
    CropperStyleKey: CropperStyleDefault,
    
    MaximumFrameRateKey: 4.0,
    RecognitionLevelKey: VNRequestTextRecognitionLevel.fast.rawValue,
    MinimumTextHeightKey: systemDefaultMinimumTextHeight,
    
    IsOpenLemmaKey: false,
    
    IsAddLineBreakKey: false,
    IsAddSpaceKey: true,
    
    HighlightModeKey: HighlightModeDefault,
    
    HLRectangleColorKey: HLRectangleColorDefault,
    
    IsShowIndexKey: false,
    StrokeDownwardOffsetKey: 5.0,
    StrokeLineWidthKey: 1.6,
    StrokeDashPaintedKey: 1.0,
    StrokeDashUnPaintedKey: 3.0,
    IndexPaddingKey: 1.5,
    IndexFontSizeKey: 5,
    
    IsAlwaysRefreshHighlightKey: false,
]

// all defaults
private let universalKV: [String: Any] = scenarioKV.merging([
    IsFinishedOnboardingKey: false,
    
    IsShowKnownKey: false,
    IsShowKnownButWithOpacity0Key: false,
    IsConcealTranslationKey: false,
    IsShowNotFoundKey: false,
    IsShowToastKey: true,
    
    DoNameRecognitionKey: false,
    DoPhraseDetectionKey: false,
    
    UseAppleDictModeKey: UseAppleDictMode.afterBuiltIn.rawValue,
    UseEntryModeKey: UseEntryMode.asFirstPriority.rawValue,
    
    IsDropTitleWordKey: false,
    IsDropFirstTitleWordInTranslationKey: true,
    IsJoinTranslationLinesKey: true,
    ChineseCharacterConvertModeKey: ChineseCharacterConvertMode.notConvert.rawValue,

    // Appearance
    FontNameKey: defaultFontName,
    FontRatioKey: 0.9,

    WordColorKey: colorToData(NSColor.labelColor)!,
    TransColorKey: colorToData(NSColor.secondaryLabelColor)!,
    BackgroundColorKey: BackgroundColorDefault,
    
    UseContentBackgroundVisualEffectKey: false,
    ContentBackGroundVisualEffectMaterialKey: NSVisualEffectView.Material.titlebar.rawValue,
    
    TheColorSchemeKey: TheColorScheme.system.rawValue,
    
    IsWithAnimationKey: true,
    
    HLDottedColorKey: colorToData(NSColor.red)!,
    
    IndexXBasicKey: IndexXBasic.trailing.rawValue,
    IndexColorKey: colorToData(NSColor.windowBackgroundColor)!,
    ContentIndexColorKey: colorToData(NSColor.systemOrange)!,
    IndexBgColorKey: colorToData(NSColor.labelColor)!,
]) { (current, _) in current }

func initAllUserDefaultsIfNil() {
    for (key, value) in universalKV {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.setValue(value, forKey: key)
        }
    }
}

extension UserDefaults {
    // some combine or both in slots
    @objc var IsShowKnownKey: Bool {
        get { return bool(forKey: "IsShowKnownKey") }
        set { set(newValue, forKey: "IsShowKnownKey") }
    }
    @objc var IsShowKnownButWithOpacity0Key: Bool {
        get { return bool(forKey: "IsShowKnownButWithOpacity0Key") }
        set { set(newValue, forKey: "IsShowKnownButWithOpacity0Key") }
    }
    @objc var IsShowNotFoundKey: Bool {
        get { return bool(forKey: "IsShowNotFoundKey" )}
        set { set(newValue, forKey: "IsShowNotFoundKey") }
    }

    @objc var CropperStyleKey: Int {
        get { return integer(forKey: "CropperStyleKey") }
        set { set(newValue, forKey: "CropperStyleKey") }
    }

    @objc var MaximumFrameRateKey: Double {
        get { return double(forKey: "MaximumFrameRateKey") }
        set { set(newValue, forKey: "MaximumFrameRateKey") }
    }
    @objc var RecognitionLevelKey: Int {
        get { return integer(forKey: "RecognitionLevelKey") }
        set { set(newValue, forKey: "RecognitionLevelKey") }
    }
    @objc var MinimumTextHeightKey: Double {
        get { return double(forKey: "MinimumTextHeightKey") }
        set { set(newValue, forKey: "MinimumTextHeightKey") }
    }

    @objc var IsOpenLemmaKey: Bool {
        get { return bool(forKey: "IsOpenLemmaKey") }
        set { set(newValue, forKey: "IsOpenLemmaKey") }
    }
    @objc var DoNameRecognitionKey: Bool {
        get { return bool(forKey: "DoNameRecognitionKey") }
        set { set(newValue, forKey: "DoNameRecognitionKey") }
    }
    @objc var DoPhraseDetectionKey: Bool {
        get { return bool(forKey: "DoPhraseDetectionKey") }
        set { set(newValue, forKey: "DoPhraseDetectionKey") }
    }

    @objc var UseAppleDictModeKey: Int {
        get { return integer(forKey: "UseAppleDictModeKey") }
        set { set(newValue, forKey: "UseAppleDictModeKey") }
    }
    @objc var UseEntryModeKey: Int {
        get { return integer(forKey: "UseEntryModeKey") }
        set { set(newValue, forKey: "UseEntryModeKey") }
    }
    
    //// Slot
    @objc var PortraitCornerKey: Int {
        get { return integer(forKey: "PortraitCornerKey") }
        set { set(newValue, forKey: "PortraitCornerKey") }
    }
    @objc var PortraitMaxHeightKey: Double {
        get { return double(forKey: "PortraitMaxHeightKey") }
        set { set(newValue, forKey: "PortraitMaxHeightKey") }
    }
    @objc var LandscapeStyleKey: Int {
        get { return integer(forKey: "LandscapeStyleKey") }
        set { set(newValue, forKey: "LandscapeStyleKey") }
    }
    @objc var LandscapeMaxWidthKey: Double {
        get { return double(forKey: "LandscapeMaxWidthKey") }
        set { set(newValue, forKey: "LandscapeMaxWidthKey") }
    }
    
    @objc var ContentPaddingStyleKey: Int {
        get { return integer(forKey: "ContentPaddingStyleKey") }
        set { set(newValue, forKey: "ContentPaddingStyleKey") }
    }
    @objc var StandardCornerRadiusKey: Double {
        get { return double(forKey: "StandardCornerRadiusKey") }
        set { set(newValue, forKey: "StandardCornerRadiusKey") }
    }
    @objc var MinimalistVPaddingKey: Double {
        get { return double(forKey: "MinimalistVPaddingKey") }
        set { set(newValue, forKey: "MinimalistVPaddingKey") }
    }
    @objc var MinimalistHPaddingKey: Double {
        get { return double(forKey: "MinimalistHPaddingKey") }
        set { set(newValue, forKey: "MinimalistHPaddingKey") }
    }
    
    @objc var FontSizeKey: Int {
        get { return integer(forKey: "FontSizeKey") }
        set { set(newValue, forKey: "FontSizeKey") }
    }
    @objc var LineSpacingKey: Double {
        get { return double(forKey: "LineSpacingKey") }
        set { set(newValue, forKey: "LineSpacingKey") }
    }
    
    @objc var IsAddLineBreakKey: Bool {
        get { return bool(forKey: "IsAddLineBreakKey") }
        set { set(newValue, forKey: "IsAddLineBreakKey") }
    }
    @objc var IsAddSpaceKey: Bool {
        get { return bool(forKey: "IsAddSpaceKey") }
        set { set(newValue, forKey: "IsAddSpaceKey") }
    }
    
    @objc var HighlightModeKey: Int {
        get { return integer(forKey: "HighlightModeKey") }
        set { set(newValue, forKey: "HighlightModeKey") }
    }
    @objc var HLRectangleColorKey: Data {
        get { return data(forKey: "HLRectangleColorKey")! }
        set { set(newValue, forKey: "HLRectangleColorKey") }
    }
    @objc var IsShowIndexKey: Bool {
        get { return bool(forKey: "IsShowIndexKey") }
        set { set(newValue, forKey: "IsShowIndexKey") }
    }
    @objc var StrokeDownwardOffsetKey: Double {
        get { return double(forKey: "StrokeDownwardOffsetKey") }
        set { set(newValue, forKey: "StrokeDownwardOffsetKey") }
    }
    @objc var StrokeLineWidthKey: Double {
        get { return double(forKey: "StrokeLineWidthKey") }
        set { set(newValue, forKey: "StrokeLineWidthKey") }
    }
    @objc var StrokeDashPaintedKey: Double {
        get { return double(forKey: "StrokeDashPaintedKey") }
        set { set(newValue, forKey: "StrokeDashPaintedKey") }
    }
    @objc var StrokeDashUnPaintedKey: Double {
        get { return double(forKey: "StrokeDashUnPaintedKey") }
        set { set(newValue, forKey: "StrokeDashUnPaintedKey") }
    }
    @objc var IndexPaddingKey: Double {
        get { return double(forKey: "IndexPaddingKey") }
        set { set(newValue, forKey: "IndexPaddingKey") }
    }
    @objc var IndexFontSizeKey: Int {
        get { return integer(forKey: "IndexFontSizeKey") }
        set { set(newValue, forKey: "IndexFontSizeKey") }
    }
    @objc var IsAlwaysRefreshHighlightKey: Bool {
        get { return bool(forKey: "IsAlwaysRefreshHighlightKey") }
        set { set(newValue, forKey: "IsAlwaysRefreshHighlightKey") }
    }
}

var subscriptions = Set<AnyCancellable>()

func combineWindows() {
    UserDefaults.standard
        .publisher(for: \.CropperStyleKey)
        .handleEvents(receiveOutput: { cropperStyle in
            if !UserDefaults.standard.bool(forKey: IsFinishedOnboardingKey) { // we don't want to display any cropper during onboarding process
                return
            }
            if !statusData.isPlaying { // we don't want to display cropper when not plaing
                return
            }
            syncCropperView(from: CropperStyle(rawValue: cropperStyle)!)
            logger.info("did syncCropperView")
        })
        .sink { _ in }
        .store(in: &subscriptions)
}

func combineFPS() {
    UserDefaults.standard
        .publisher(for: \.MaximumFrameRateKey)
        .handleEvents(receiveOutput: { fps in
            if statusData.isPlaying {
                aVSessionAndTR.stopScreenCapture()
                aVSessionAndTR.startScreenCapture()
            }
            logger.info("did combine fps")
        })
        .sink { _ in }
        .store(in: &subscriptions)
}
    
// NLP settings combine trCallBack
func combineNLPSettings() {
    UserDefaults.standard
        .publisher(for: \.IsOpenLemmaKey)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
        
    UserDefaults.standard
        .publisher(for: \.DoNameRecognitionKey)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.DoPhraseDetectionKey)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
}

// Dictionary settings combine trCallBack and more
func combineDictionarySettings() {
    UserDefaults.standard
        .publisher(for: \.UseAppleDictModeKey)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.UseEntryModeKey)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
}

func combineShortcutKeyFnsSettings() {
    UserDefaults.standard
        .publisher(for: \.IsShowKnownKey)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.IsShowKnownButWithOpacity0Key)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.IsShowNotFoundKey)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
}

func combineHighlight() {
    UserDefaults.standard
        .publisher(for: \.HighlightModeKey)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
}

func autoSaveSlotSettings() {
    combineSlot(\.PortraitCornerKey, \.portraitCorner, PortraitCornerKey)
    combineSlot(\.PortraitMaxHeightKey, \.portraitMaxHeight, PortraitMaxHeightKey)
    combineSlot(\.LandscapeStyleKey, \.landscapeStyle, LandscapeStyleKey)
    combineSlot(\.LandscapeMaxWidthKey, \.landscapeMaxWidth, LandscapeMaxWidthKey)
    
    combineSlot(\.ContentPaddingStyleKey, \.contentPaddingStyle, ContentPaddingStyleKey)
    combineSlot(\.StandardCornerRadiusKey, \.standardCornerRadius, StandardCornerRadiusKey)
    combineSlot(\.MinimalistVPaddingKey, \.minimalistVPadding, MinimalistVPaddingKey)
    combineSlot(\.MinimalistHPaddingKey, \.minimalistHPadding, MinimalistHPaddingKey)
    
    combineSlot(\.FontSizeKey, \.fontSize, FontSizeKey)
    combineSlot(\.LineSpacingKey, \.lineSpacing, LineSpacingKey)
    
    combineSlot(\.CropperStyleKey, \.cropperStyle, CropperStyleKey)
    
    combineSlot(\.MaximumFrameRateKey, \.maximumFrameRate, MaximumFrameRateKey)
    combineSlot(\.RecognitionLevelKey, \.recognitionLevel, RecognitionLevelKey)
    combineSlot(\.MinimumTextHeightKey, \.minimumTextHeight, MinimumTextHeightKey)
    combineSlot(\.IsOpenLemmaKey, \.isOpenLemma, IsOpenLemmaKey)
    
    combineSlot(\.IsAddLineBreakKey, \.isAddLineBreak, IsAddLineBreakKey)
    combineSlot(\.IsAddSpaceKey, \.isAddSpace, IsAddSpaceKey)
    
    combineSlot(\.HighlightModeKey, \.highlightMode, HighlightModeKey)
    combineSlot(\.HLRectangleColorKey, \.hLRectangleColor, HLRectangleColorKey)
    combineSlot(\.IsShowIndexKey, \.isShowIndex, IsShowIndexKey)
    combineSlot(\.StrokeDownwardOffsetKey, \.strokeDownwardOffset, StrokeDownwardOffsetKey)
    combineSlot(\.StrokeLineWidthKey, \.strokeLineWidth, StrokeLineWidthKey)
    combineSlot(\.StrokeDashPaintedKey, \.strokeDashPainted, StrokeDashPaintedKey)
    combineSlot(\.StrokeDashUnPaintedKey, \.strokeDashUnPainted, StrokeDashUnPaintedKey)
    combineSlot(\.IndexPaddingKey, \.indexPadding, IndexPaddingKey)
    combineSlot(\.IndexFontSizeKey, \.indexFontSize, IndexFontSizeKey)
    combineSlot(\.IsAlwaysRefreshHighlightKey, \.isAlwaysRefreshHighlight, IsAlwaysRefreshHighlightKey)
}

private func combineSlot<T>(
    _ keypathUserDefaultValue: KeyPath<UserDefaults, T>,
    _ keypathSettingsValue: WritableKeyPath<Settings, T>,
    _ keypathName: String
) {
    UserDefaults.standard
        .publisher(for: keypathUserDefaultValue)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    var settings = dataToSettings(slot.settings!)!
                    settings[keyPath: keypathSettingsValue] = newValue
                    slot.settings = settingsToData(settings)
                    saveContext()
                    logger.info("did save slot \(keypathName, privacy: .public)")
                    return
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
}
