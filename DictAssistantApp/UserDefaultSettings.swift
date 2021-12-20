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
let IsShowCurrentKnownKey = "IsShowCurrentKnownKey" // not in slot for its core function
let IsShowCurrentKnownButWithOpacity0Key = "IsShowCurrentKnownButWithOpacity0Key"
let IsConcealTranslationKey = "IsConcealTranslationKey"
let IsShowCurrentNotFoundWordsKey = "IsShowCurrentNotFoundWordsKey"

let ShowToastToggleKey = "ShowToastToggleKey" // not in slot for basic consistence of an auxiliary extra trick

// Recording
let CropperStyleKey = "CropperStyleKey"

let HighlightModeKey = "HighlightModeKey"

let HLRectangleColorKey = "HLRectangleColorKey"

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
let ContentIndexFontSizeKey = "ContentIndexFontSizeKey"

let IsAlwaysRefreshHighlightKey = "IsAlwaysRefreshHighlightKey"

let IsCloseCropperWhenNotPlayingKey = "IsCloseCropperWhenNotPlayingKey"
let MaximumFrameRateKey = "MaximumFrameRateKey"

// Vision
let TRTextRecognitionLevelKey = "TRTextRecognitionLevelKey"
let TRMinimumTextHeightKey = "TRMinimumTextHeightKey"

// NLP
let LemmaSearchLevelKey = "LemmaSearchLevelKey"
let DoNameRecognitionKey = "DoNameRecognitionKey"
let DoPhraseRecognitionKey = "DoPhraseRecognitionKey"

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
let ContentStyleKey = "ContentStyleKey"
let PortraitCornerKey = "PortraitCornerKey"
let PortraitMaxHeightKey = "PortraitMaxHeightKey"
let LandscapeStyleKey = "LandscapeStyleKey"
let LandscapeMaxWidthKey = "LandscapeMaxWidthKey"

let FontSizeKey = "FontSizeKey"
let LineSpacingKey = "LineSpacingKey"
let FontRateKey = "FontRateKey"

let WordColorKey = "WordColorKey"
let TransColorKey = "TransColorKey"
let BackgroundColorKey = "BackgroundColorKey"

let TextShadowToggleKey = "TextShadowToggleKey"
let ShadowColorKey = "ShadowColorKey"
let ShadowRadiusKey = "ShadowRadiusKey"
let ShadowXOffSetKey = "ShadowXOffSetKey"
let ShadowYOffSetKey = "ShadowYOffSetKey"

let ContentCornerRadiusKey = "ContentCornerRadiusKey"
let UseContentBackgroundVisualEffectKey = "UseContentBackgroundVisualEffectKey"
let ContentBackGroundVisualEffectMaterialKey = "ContentBackGroundVisualEffectMaterialKey"

let TheColorSchemeKey = "TheColorSchemeKey"

let IsShowWindowShadowKey = "IsShowWindowShadowKey"
let IsWithAnimationKey = "IsWithAnimationKey"
let IsContentRetentionKey = "IsContentRetentionKey"

// Enums
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

enum LemmaSearchLevel: Int, Codable {
    case apple = 0
    case database = 1
    case open = 2
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

enum ContentStyle: Int, Codable {
    case portrait = 0
    case landscape = 1
}

enum PortraitCorner: Int, Codable {
    case topTrailing = 0
    case topLeading = 1
    case bottomLeading = 2
    case top = 3
}

enum LandscapeStyle: Int, Codable {
    case normal = 0
    case autoScrolling = 1
    case centered = 2
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
    MaximumFrameRateKey: 4,
    
    TRTextRecognitionLevelKey: VNRequestTextRecognitionLevel.fast.rawValue,
    TRMinimumTextHeightKey: systemDefaultMinimumTextHeight,
    
    CropperStyleKey: CropperStyle.leadingBorder.rawValue,
    IsCloseCropperWhenNotPlayingKey: true,
    
    ContentStyleKey: ContentStyle.portrait.rawValue,
    PortraitCornerKey: PortraitCorner.topTrailing.rawValue,
    PortraitMaxHeightKey: 100.0,
    LandscapeStyleKey: LandscapeStyle.normal.rawValue,
    LandscapeMaxWidthKey: 160.0,
    
    FontSizeKey: 14.0,
    LineSpacingKey: 0.0,
    FontRateKey: 0.9,
]

// all defaults
private let universalKV: [String: Any] = scenarioKV.merging([
    IsFinishedOnboardingKey: false,
    
    FontNameKey: defaultFontName,
    
    // General:
    IsShowCurrentKnownKey: false,
    IsShowCurrentKnownButWithOpacity0Key: false,
    IsConcealTranslationKey: false,
    IsShowCurrentNotFoundWordsKey: false,
    ShowToastToggleKey: true,
    
    // NLP:
    LemmaSearchLevelKey: LemmaSearchLevel.database.rawValue,
    DoNameRecognitionKey: false,
    DoPhraseRecognitionKey: false,
    
    // Dictionary:
    UseAppleDictModeKey: UseAppleDictMode.afterBuiltIn.rawValue,
    UseEntryModeKey: UseEntryMode.asFirstPriority.rawValue,
    
    // Appearance:
    WordColorKey: colorToData(NSColor.labelColor)!,
    TransColorKey: colorToData(NSColor.secondaryLabelColor)!,
    BackgroundColorKey: colorToData(NSColor.windowBackgroundColor)!,
    
    TextShadowToggleKey: false,
    ShadowColorKey: colorToData(NSColor.labelColor)!,
    ShadowRadiusKey: 3,
    ShadowXOffSetKey: 0.0,
    ShadowYOffSetKey: 0.0,
    
    ContentCornerRadiusKey: 10.0,
    UseContentBackgroundVisualEffectKey: false,
    ContentBackGroundVisualEffectMaterialKey: NSVisualEffectView.Material.titlebar.rawValue,
    
    TheColorSchemeKey: TheColorScheme.system.rawValue,
    
    IsShowWindowShadowKey: true,
    IsWithAnimationKey: true,
    IsContentRetentionKey: false,
    
    // Transcript:
    IsDropTitleWordKey: false,
    IsAddLineBreakKey: true,
    IsAddSpaceKey: false,
    IsDropFirstTitleWordInTranslationKey: true,
    IsJoinTranslationLinesKey: true,
    ChineseCharacterConvertModeKey: ChineseCharacterConvertMode.notConvert.rawValue,
    
    // Cropper
    HighlightModeKey: HighlightMode.dotted.rawValue,
    
    HLRectangleColorKey: colorToData(NSColor.red.withAlphaComponent(0.15))!,
    HLDottedColorKey: colorToData(NSColor.red)!,
    StrokeDownwardOffsetKey: 5.0,
    StrokeLineWidthKey: 3.0,
    StrokeDashPaintedKey: 1.6,
    StrokeDashUnPaintedKey: 3.0,
    
    IsShowIndexKey: true,
    IndexColorKey: colorToData(NSColor.windowBackgroundColor)!,
    ContentIndexColorKey: colorToData(NSColor.labelColor)!,
    IndexBgColorKey: colorToData(NSColor.labelColor)!,
    IndexPaddingKey: 2.0,
    IndexXBasicKey: IndexXBasic.trailing.rawValue,
    IndexFontSizeKey: 7.0,
    ContentIndexFontSizeKey: 13.0,
    
    IsAlwaysRefreshHighlightKey: false,
    
]) { (current, _) in current }

func initAllUserDefaultsIfNil() {
    for (key, value) in universalKV {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.setValue(value, forKey: key)
        }
    }
}

extension UserDefaults {
    @objc var CropperStyleKey: Int {
        get { return integer(forKey: "CropperStyleKey") }
        set { set(newValue, forKey: "CropperStyleKey") }
    }
    
    @objc var IsCloseCropperWhenNotPlayingKey: Bool {
        get { return bool(forKey: "IsCloseCropperWhenNotPlayingKey") }
        set { set(newValue, forKey: "IsCloseCropperWhenNotPlayingKey") }
    }
    @objc var MaximumFrameRateKey: Double {
        get { return double(forKey: "MaximumFrameRateKey") }
        set { set(newValue, forKey: "MaximumFrameRateKey") }
    }
    
    @objc var TRTextRecognitionLevelKey: Int {
        get { return integer(forKey: "TRTextRecognitionLevelKey") }
        set { set(newValue, forKey: "TRTextRecognitionLevelKey") }
    }
    @objc var TRMinimumTextHeightKey: Double {
        get { return double(forKey: "TRMinimumTextHeightKey") }
        set { set(newValue, forKey: "TRMinimumTextHeightKey") }
    }
    
    @objc var LemmaSearchLevelKey: Int {
        get { return integer(forKey: "LemmaSearchLevelKey") }
        set { set(newValue, forKey: "LemmaSearchLevelKey") }
    }
    @objc var DoNameRecognitionKey: Bool {
        get { return bool(forKey: "DoNameRecognitionKey") }
        set { set(newValue, forKey: "DoNameRecognitionKey") }
    }
    @objc var DoPhraseRecognitionKey: Bool {
        get { return bool(forKey: "DoPhraseRecognitionKey") }
        set { set(newValue, forKey: "DoPhraseRecognitionKey") }
    }
    
    @objc var UseAppleDictModeKey: Int {
        get { return integer(forKey: "UseAppleDictModeKey") }
        set { set(newValue, forKey: "UseAppleDictModeKey") }
    }
    @objc var UseEntryModeKey: Int {
        get { return integer(forKey: "UseEntryModeKey") }
        set { set(newValue, forKey: "UseEntryModeKey") }
    }
    
    @objc var ContentStyleKey: Int {
        get { return integer(forKey: "ContentStyleKey") }
        set { set(newValue, forKey: "ContentStyleKey") }
    }
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
    
    @objc var FontSizeKey: Double {
        get { return double(forKey: "FontSizeKey") }
        set { set(newValue, forKey: "FontSizeKey") }
    }
    @objc var LineSpacingKey: Double {
        get { return double(forKey: "LineSpacingKey") }
        set { set(newValue, forKey: "LineSpacingKey") }
    }
    @objc var FontRateKey: Double {
        get { return double(forKey: "FontRateKey") }
        set { set(newValue, forKey: "FontRateKey") }
    }
    
    @objc var IsShowWindowShadowKey: Bool {
        get { return bool(forKey: "IsShowWindowShadowKey") }
        set { set(newValue, forKey: "IsShowWindowShadowKey") }
    }
}

var subscriptions = Set<AnyCancellable>()

func combineWindows() {
    UserDefaults.standard
        .publisher(for: \.CropperStyleKey)
        .handleEvents(receiveOutput: { cropperStyle in
            if !UserDefaults.standard.bool(forKey: IsFinishedOnboardingKey) { // we don't want display any cropper during onboarding process
                return
            }
            syncCropperView(from: CropperStyle(rawValue: cropperStyle)!)
            logger.info("did syncCropperView")
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.IsCloseCropperWhenNotPlayingKey)
        .handleEvents(receiveOutput: { isCloseCropperWhenNotPlaying in
            if !statusData.isPlaying {
                if isCloseCropperWhenNotPlaying {
                    cropperWindow.close()
                } else {
                    cropperWindow.orderFrontRegardless()
                }
            }
            logger.info("did close or show cropperWindow")
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.IsShowWindowShadowKey)
        .handleEvents(receiveOutput: { isShowWindowShadow in
            syncContentWindowShadow(from: isShowWindowShadow)
            logger.info("did syncContentWindowShadow")
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
        .publisher(for: \.LemmaSearchLevelKey)
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
        .publisher(for: \.DoPhraseRecognitionKey)
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

func autoSaveSlotSettings() {
    combineSlot(\.MaximumFrameRateKey, \.maximumFrameRate, MaximumFrameRateKey)
    
    combineSlot(\.TRTextRecognitionLevelKey, \.tRTextRecognitionLevel, TRTextRecognitionLevelKey)
    combineSlot(\.TRMinimumTextHeightKey, \.tRMinimumTextHeight, TRMinimumTextHeightKey)
    
    combineSlot(\.CropperStyleKey, \.cropperStyle, CropperStyleKey)
    combineSlot(\.IsCloseCropperWhenNotPlayingKey, \.isCloseCropperWhenNotPlaying, IsCloseCropperWhenNotPlayingKey)
    
    combineSlot(\.ContentStyleKey, \.contentStyle, ContentStyleKey)
    combineSlot(\.PortraitCornerKey, \.portraitCorner, PortraitCornerKey)
    combineSlot(\.PortraitMaxHeightKey, \.portraitMaxHeight, PortraitMaxHeightKey)
    combineSlot(\.LandscapeStyleKey, \.landscapeStyle, LandscapeStyleKey)
    combineSlot(\.LandscapeMaxWidthKey, \.landscapeMaxWidth, LandscapeMaxWidthKey)
    
    combineSlot(\.FontSizeKey, \.fontSize, FontSizeKey)
    combineSlot(\.LineSpacingKey, \.lineSpacing, LineSpacingKey)
    combineSlot(\.FontRateKey, \.fontRate, FontRateKey)
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
