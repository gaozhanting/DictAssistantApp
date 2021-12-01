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
let IsCloseCropperWhenNotPlayingKey = "IsCloseCropperWhenNotPlayingKey"
let MaximumFrameRateKey = "MaximumFrameRateKey"

// Vision
let TRTextRecognitionLevelKey = "TRTextRecognitionLevelKey"
let TRMinimumTextHeightKey = "TRMinimumTextHeightKey"

// English
let TitleWordKey = "TitleWordKey"
let LemmaSearchLevelKey = "LemmaSearchLevelKey"
let IsShowPhrasesKey = "IsShowPhrasesKey"
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

let UseContentBackgroundColorKey = "UseContentBackgroundColorKey"
let UseContentBackgroundVisualEffectKey = "UseContentBackgroundVisualEffectKey"
let ContentBackGroundVisualEffectMaterialKey = "ContentBackGroundVisualEffectMaterialKey"

let TheColorSchemeKey = "TheColorSchemeKey"

let IsShowWindowShadowKey = "IsShowWindowShadowKey"
let IsWithAnimationKey = "IsWithAnimationKey"
let IsContentRetentionKey = "IsContentRetentionKey"

// Enums
enum CropperStyle: Int, Codable {
    case empty = 0
    case rectangle = 1
    case leadingBorder = 2
    case trailingBorder = 3
    case strokeBorder = 4
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
private let defaultSlotKV: [String: Any] = [
    // Recording
    CropperStyleKey: CropperStyle.leadingBorder.rawValue,
    IsCloseCropperWhenNotPlayingKey: true,
    MaximumFrameRateKey: 4,
    
    // Vision
    TRTextRecognitionLevelKey: VNRequestTextRecognitionLevel.fast.rawValue,
    TRMinimumTextHeightKey: systemDefaultMinimumTextHeight,
    
    // English
    TitleWordKey: TitleWord.lemma.rawValue,
    LemmaSearchLevelKey: LemmaSearchLevel.database.rawValue,
    IsShowPhrasesKey: false,
    UseAppleDictModeKey: UseAppleDictMode.afterBuiltIn.rawValue,
    UseEntryModeKey: UseEntryMode.asFirstPriority.rawValue,
    
    // Content
    IsDropTitleWordKey: false,
    IsAddLineBreakKey: true,
    IsAddSpaceKey: false,
    IsDropFirstTitleWordInTranslationKey: true,
    IsJoinTranslationLinesKey: true,
    ChineseCharacterConvertModeKey: ChineseCharacterConvertMode.notConvert.rawValue,
    
    // Appearance
    ContentStyleKey: ContentStyle.portrait.rawValue,
    PortraitCornerKey: PortraitCorner.topTrailing.rawValue,
    PortraitMaxHeightKey: 100.0,
    LandscapeStyleKey: LandscapeStyle.normal.rawValue,
    LandscapeMaxWidthKey: 160.0,
    
    FontSizeKey: 14.0,
    LineSpacingKey: 0.0,
    FontRateKey: 0.9,
    
    WordColorKey: colorToData(NSColor.labelColor)!,
    TransColorKey: colorToData(NSColor.secondaryLabelColor)!,
    BackgroundColorKey: colorToData(NSColor.windowBackgroundColor)!,
    
    TextShadowToggleKey: false,
    ShadowColorKey: colorToData(NSColor.labelColor)!,
    ShadowRadiusKey: 3,
    ShadowXOffSetKey: 0.0,
    ShadowYOffSetKey: 0.0,
    
    UseContentBackgroundColorKey: true,
    UseContentBackgroundVisualEffectKey: false,
    ContentBackGroundVisualEffectMaterialKey: NSVisualEffectView.Material.titlebar.rawValue,
    
    TheColorSchemeKey: TheColorScheme.system.rawValue,
    
    IsShowWindowShadowKey: true,
    IsWithAnimationKey: true,
    IsContentRetentionKey: false,
]

// all defaults
private let defaultKV: [String: Any] = defaultSlotKV.merging([
    IsShowCurrentKnownKey: false,
    IsShowCurrentKnownButWithOpacity0Key: false,
    IsConcealTranslationKey: false,
    IsShowCurrentNotFoundWordsKey: false,
    ShowToastToggleKey: true,
    IsFinishedOnboardingKey: false,
    FontNameKey: defaultFontName,
]) { (current, _) in current }

func initAllUserDefaultsIfNil() {
    for (key, value) in defaultKV {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.setValue(value, forKey: key)
        }
    }
}

extension UserDefaults {
    // Recording
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
    
    // Vision
    @objc var TRTextRecognitionLevelKey: Int {
        get { return integer(forKey: "TRTextRecognitionLevelKey") }
        set { set(newValue, forKey: "TRTextRecognitionLevelKey") }
    }
    @objc var TRMinimumTextHeightKey: Double {
        get { return double(forKey: "TRMinimumTextHeightKey") }
        set { set(newValue, forKey: "TRMinimumTextHeightKey") }
    }
    
    // English
    @objc var TitleWordKey: Int {
        get { return integer(forKey: "TitleWordKey") }
        set { set(newValue, forKey: "TitleWordKey") }
    }
    @objc var LemmaSearchLevelKey: Int {
        get { return integer(forKey: "LemmaSearchLevelKey") }
        set { set(newValue, forKey: "LemmaSearchLevelKey") }
    }
    @objc var IsShowPhrasesKey: Bool {
        get { return bool(forKey: "IsShowPhrasesKey") }
        set { set(newValue, forKey: "IsShowPhrasesKey") }
    }
    @objc var UseAppleDictModeKey: Bool {
        get { return bool(forKey: "UseAppleDictModeKey") }
        set { set(newValue, forKey: "UseAppleDictModeKey") }
    }
    @objc var UseEntryModeKey: Int {
        get { return integer(forKey: "UseEntryModeKey") }
        set { set(newValue, forKey: "UseEntryModeKey") }
    }
    
    // Content
    @objc var IsDropTitleWordKey: Bool {
        get { return bool(forKey: "IsDropTitleWordKey") }
        set { set(newValue, forKey: "IsDropTitleWordKey") }
    }
    @objc var IsAddLineBreakKey: Bool {
        get { return bool(forKey: "IsAddLineBreakKey") }
        set { set(newValue, forKey: "IsAddLineBreakKey") }
    }
    @objc var IsAddSpaceKey: Bool {
        get { return bool(forKey: "IsAddSpaceKey") }
        set { set(newValue, forKey: "IsAddSpaceKey") }
    }
    @objc var IsDropFirstTitleWordInTranslationKey: Bool {
        get { return bool(forKey: "IsDropFirstTitleWordInTranslationKey") }
        set { set(newValue, forKey: "IsDropFirstTitleWordInTranslationKey") }
    }
    @objc var IsJoinTranslationLinesKey: Bool {
        get { return bool(forKey: "IsJoinTranslationLinesKey") }
        set { set(newValue, forKey: "IsJoinTranslationLinesKey") }
    }
    @objc var ChineseCharacterConvertModeKey: Int {
        get { return integer(forKey: "ChineseCharacterConvertModeKey") }
        set { set(newValue, forKey: "ChineseCharacterConvertModeKey") }
    }

    // Appearance
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
    
    @objc var WordColorKey: Data {
        get { return data(forKey: "WordColorKey")! }
        set { set(newValue, forKey: "WordColorKey") }
    }
    @objc var TransColorKey: Data {
        get { return data(forKey: "TransColorKey")! }
        set { set(newValue, forKey: "TransColorKey") }
    }
    @objc var BackgroundColorKey: Data {
        get { return data(forKey: "BackgroundColorKey")! }
        set { set(newValue, forKey: "BackgroundColorKey") }
    }
    
    @objc var TextShadowToggleKey: Bool {
        get { return bool(forKey: "TextShadowToggleKey") }
        set { set(newValue, forKey: "TextShadowToggleKey") }
    }
    @objc var ShadowColorKey: Data {
        get { return data(forKey: "ShadowColorKey")! }
        set { set(newValue, forKey: "ShadowColorKey") }
    }
    @objc var ShadowRadiusKey: Double {
        get { return double(forKey: "ShadowRadiusKey") }
        set { set(newValue, forKey: "ShadowRadiusKey") }
    }
    @objc var ShadowXOffSetKey: Double {
        get { return double(forKey: "ShadowXOffSetKey") }
        set { set(newValue, forKey: "ShadowXOffSetKey") }
    }
    @objc var ShadowYOffSetKey: Double {
        get { return double(forKey: "ShadowYOffSetKey") }
        set { set(newValue, forKey: "ShadowYOffSetKey") }
    }
    
    @objc var UseContentBackgroundColorKey: Bool {
        get { return bool(forKey: "UseContentBackgroundColorKey") }
        set { set(newValue, forKey: "UseContentBackgroundColorKey") }
    }
    @objc var UseContentBackgroundVisualEffectKey: Bool {
        get { return bool(forKey: "UseContentBackgroundVisualEffectKey") }
        set { set(newValue, forKey: "UseContentBackgroundVisualEffectKey") }
    }
    @objc var ContentBackGroundVisualEffectMaterialKey: Int {
        get { return integer(forKey: "ContentBackGroundVisualEffectMaterialKey") }
        set { set(newValue, forKey: "ContentBackGroundVisualEffectMaterialKey") }
    }
    
    @objc var TheColorSchemeKey: Int {
        get { return integer(forKey: "TheColorSchemeKey") }
        set { set(newValue, forKey: "TheColorSchemeKey") }
    }
    
    @objc var IsShowWindowShadowKey: Bool {
        get { return bool(forKey: "IsShowWindowShadowKey") }
        set { set(newValue, forKey: "IsShowWindowShadowKey") }
    }
    @objc var IsWithAnimationKey: Bool {
        get { return bool(forKey: "IsWithAnimationKey") }
        set { set(newValue, forKey: "IsWithAnimationKey") }
    }
    @objc var IsContentRetentionKey: Bool {
        get { return bool(forKey: "IsContentRetentionKey") }
        set { set(newValue, forKey: "IsContentRetentionKey") }
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
                aVSessionAndTR.lastReconginzedTexts = []
                aVSessionAndTR.stopScreenCapture()
                aVSessionAndTR.startScreenCapture()
            }
            logger.info("did combine fps")
        })
        .sink { _ in }
        .store(in: &subscriptions)
}
    
// English settings combine trCallBack and more
func combineEnglishSettings() {
    UserDefaults.standard
        .publisher(for: \.TitleWordKey)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.LemmaSearchLevelKey)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.IsShowPhrasesKey)
        .handleEvents(receiveOutput: { _ in
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.UseAppleDictModeKey)
        .handleEvents(receiveOutput: { _ in
            cachedDict = [:]
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.UseEntryModeKey)
        .handleEvents(receiveOutput: { _ in
            cachedDict = [:]
            trCallBack()
        })
        .sink { _ in }
        .store(in: &subscriptions)
}

func autoSaveSlotSettings() {
    // Recording
    combineSlot(\.CropperStyleKey, \.cropperStyle, CropperStyleKey)
    combineSlot(\.IsCloseCropperWhenNotPlayingKey, \.isCloseCropperWhenNotPlaying, IsCloseCropperWhenNotPlayingKey)
    combineSlot(\.MaximumFrameRateKey, \.maximumFrameRate, MaximumFrameRateKey)
    
    // Vision
    combineSlot(\.TRTextRecognitionLevelKey, \.tRTextRecognitionLevel, TRTextRecognitionLevelKey)
    combineSlot(\.TRMinimumTextHeightKey, \.tRMinimumTextHeight, TRMinimumTextHeightKey)
    
    // English
    combineSlot(\.TitleWordKey, \.titleWord, TitleWordKey)
    combineSlot(\.LemmaSearchLevelKey, \.lemmaSearchLevel, LemmaSearchLevelKey)
    combineSlot(\.IsShowPhrasesKey, \.isShowPhrases, IsShowPhrasesKey)
    combineSlot(\.UseEntryModeKey, \.useEntryMode, UseEntryModeKey)
    
    // Content
    combineSlot(\.IsDropTitleWordKey, \.isDropTitleWord, IsDropTitleWordKey)
    combineSlot(\.IsAddLineBreakKey, \.isAddLineBreak, IsAddLineBreakKey)
    combineSlot(\.IsAddSpaceKey, \.isAddSpace, IsAddSpaceKey)
    combineSlot(\.IsDropFirstTitleWordInTranslationKey, \.isDropFirstTitleWordInTranslation, IsDropFirstTitleWordInTranslationKey)
    combineSlot(\.IsJoinTranslationLinesKey, \.isJoinTranslationLines, IsJoinTranslationLinesKey)
    combineSlot(\.ChineseCharacterConvertModeKey, \.chineseCharacterConvertMode, ChineseCharacterConvertModeKey)
    
    // Appearance
    combineSlot(\.ContentStyleKey, \.contentStyle, ContentStyleKey)
    combineSlot(\.PortraitCornerKey, \.portraitCorner, PortraitCornerKey)
    combineSlot(\.PortraitMaxHeightKey, \.portraitMaxHeight, PortraitMaxHeightKey)
    combineSlot(\.LandscapeStyleKey, \.landscapeStyle, LandscapeStyleKey)
    combineSlot(\.LandscapeMaxWidthKey, \.landscapeMaxWidth, LandscapeMaxWidthKey)
    
    combineSlot(\.FontSizeKey, \.fontSize, FontSizeKey)
    combineSlot(\.LineSpacingKey, \.lineSpacing, LineSpacingKey)
    combineSlot(\.FontRateKey, \.fontRate, FontRateKey)
    
    combineSlot(\.WordColorKey, \.wordColor, WordColorKey)
    combineSlot(\.TransColorKey, \.transColor, TransColorKey)
    combineSlot(\.BackgroundColorKey, \.backgroundColor, BackgroundColorKey)
    
    combineSlot(\.TextShadowToggleKey, \.textShadowToggle, TextShadowToggleKey)
    combineSlot(\.ShadowColorKey, \.shadowColor, ShadowColorKey)
    combineSlot(\.ShadowRadiusKey, \.shadowRadius, ShadowRadiusKey)
    combineSlot(\.ShadowXOffSetKey, \.shadowXOffSet, ShadowXOffSetKey)
    combineSlot(\.ShadowYOffSetKey, \.shadowYOffSet, ShadowYOffSetKey)
    
    combineSlot(\.UseContentBackgroundColorKey, \.useContentBackgroundColor, UseContentBackgroundColorKey)
    combineSlot(\.UseContentBackgroundVisualEffectKey, \.useContentBackgroundVisualEffect, UseContentBackgroundVisualEffectKey)
    combineSlot(\.ContentBackGroundVisualEffectMaterialKey, \.contentBackGroundVisualEffectMaterial, ContentBackGroundVisualEffectMaterialKey)
    
    combineSlot(\.TheColorSchemeKey, \.theColorScheme, TheColorSchemeKey)
    
    combineSlot(\.IsContentRetentionKey, \.isContentRetention, IsContentRetentionKey)
    combineSlot(\.IsShowWindowShadowKey, \.isShowWindowShadow, IsShowWindowShadowKey)
    combineSlot(\.IsWithAnimationKey, \.isWithAnimation, IsWithAnimationKey)
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
