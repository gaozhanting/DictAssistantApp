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
// -- this three not in slots
let IsShowCurrentKnownKey = "IsShowCurrentKnownKey" // not in slot for its core function
let IsShowCurrentKnownButWithOpacity0Key = "IsShowCurrentKnownButWithOpacity0Key"
let IsConcealTranslationKey = "IsConcealTranslationKey"
let IsShowCurrentNotFoundWordsKey = "IsShowCurrentNotFoundWordsKey"

let defaultFontName = NSFont.systemFont(ofSize: 0).fontName // returns ".AppleSystemUIFont"
let defaultNSFont = NSFont(name: defaultFontName, size: 18.0)!
let FontNameKey = "FontNameKey" // not in slot for basic consistence of visual

let ShowToastToggleKey = "ShowToastToggleKey" // not in slot for basic consistence of an auxiliary extra trick

let IsFinishedOnboardingKey = "IsFinishedOnboardingKey"

// general
let TRTextRecognitionLevelKey = "TRTextRecognitionLevelKey"
let TRMinimumTextHeightKey = "TRMinimumTextHeightKey"
let MaximumFrameRateKey = "MaximumFrameRateKey"

// visual
let UseEntryModeKey = "UseEntryModeKey"
let IsShowPhrasesKey = "IsShowPhrasesKey"

let CropperStyleKey = "CropperStyleKey"

let IsDropTitleWordKey = "IsDropTitleWordKey"
let IsAddLineBreakKey = "IsAddLineBreakKey"
let IsAddSpaceKey = "IsAddSpaceKey"
let IsDropFirstTitleWordInTranslationKey = "IsDropFirstTitleWordInTranslationKey"
let IsJoinTranslationLinesKey = "IsJoinTranslationLinesKey"
let ChineseCharacterConvertModeKey = "ChineseCharacterConvertModeKey"

let IsContentRetentionKey = "IsContentRetentionKey"

let IsShowWindowShadowKey = "IsShowWindowShadowKey"

let IsWithAnimationKey = "IsWithAnimationKey"

let ContentStyleKey = "ContentStyleKey"
let PortraitCornerKey = "PortraitCornerKey"
let LandscapeAutoScrollKey = "LandscapeAutoScrollKey"
let PortraitMaxHeightKey = "PortraitMaxHeightKey"
let LandscapeMaxWidthKey = "LandscapeMaxWidthKey"

let FontSizeKey = "FontSizeKey"
let FontRateKey = "FontRateKey"

let TheColorSchemeKey = "TheColorSchemeKey"

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

enum CropperStyle: Int, Codable {
    case closed = 0
    case rectangle = 1
    case leadingBorder = 2
    case trailingBorder = 3
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

enum TheColorScheme: Int, Codable {
    case light = 0
    case dark = 1
    case system = 2
}

// in slot defaults
// !! Need sync with var defaultSettings in SlotsSettingsView
fileprivate let defaultSlotKV: [String: Any] = [
    TRTextRecognitionLevelKey: VNRequestTextRecognitionLevel.fast.rawValue,
    TRMinimumTextHeightKey: systemDefaultMinimumTextHeight,
    MaximumFrameRateKey: 4,
    
    UseEntryModeKey: UseEntryMode.asFirstPriority.rawValue,
    IsShowPhrasesKey: true,
    
    CropperStyleKey: CropperStyle.leadingBorder.rawValue,
    
    IsDropTitleWordKey: false,
    IsAddLineBreakKey: true,
    IsAddSpaceKey: false,
    IsDropFirstTitleWordInTranslationKey: true,
    IsJoinTranslationLinesKey: true,
    ChineseCharacterConvertModeKey: ChineseCharacterConvertMode.notConvert.rawValue,
    
    IsContentRetentionKey: false,
    
    IsShowWindowShadowKey: true,
    
    IsWithAnimationKey: true,
    
    ContentStyleKey: ContentStyle.portrait.rawValue,
    PortraitCornerKey: PortraitCorner.topTrailing.rawValue,
    LandscapeAutoScrollKey: true,
    PortraitMaxHeightKey: 100.0,
    LandscapeMaxWidthKey: 160.0,
    
    FontSizeKey: 18.0,
    FontRateKey: 0.75,
    
    TheColorSchemeKey: TheColorScheme.system.rawValue,
    
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
]

// all defaults
fileprivate let defaultKV: [String: Any] = defaultSlotKV.merging([
    IsShowCurrentKnownKey: false,
    IsShowCurrentKnownButWithOpacity0Key: false,
    IsConcealTranslationKey: false,
    IsShowCurrentNotFoundWordsKey: false,
    FontNameKey: defaultFontName,
    ShowToastToggleKey: true,
    IsFinishedOnboardingKey: false,
]) { (current, _) in current }

func initAllUserDefaultsIfNil() {
    for (key, value) in defaultKV {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.setValue(value, forKey: key)
        }
    }
}

extension UserDefaults {
    @objc var TRTextRecognitionLevelKey: Int {
        get { return integer(forKey: "TRTextRecognitionLevelKey") }
        set { set(newValue, forKey: "TRTextRecognitionLevelKey") }
    }
    @objc var TRMinimumTextHeightKey: Double {
        get { return double(forKey: "TRMinimumTextHeightKey") }
        set { set(newValue, forKey: "TRMinimumTextHeightKey") }
    }
    @objc var MaximumFrameRateKey: Double {
        get { return double(forKey: "MaximumFrameRateKey") }
        set { set(newValue, forKey: "MaximumFrameRateKey") }
    }
    @objc var UseEntryModeKey: Int {
        get { return integer(forKey: "UseEntryModeKey") }
        set { set(newValue, forKey: "UseEntryModeKey") }
    }
    @objc var IsShowPhrasesKey: Bool {
        get { return bool(forKey: "IsShowPhrasesKey") }
        set { set(newValue, forKey: "IsShowPhrasesKey") }
    }
    @objc var CropperStyleKey: Int {
        get { return integer(forKey: "CropperStyleKey") }
        set { set(newValue, forKey: "CropperStyleKey") }
    }
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
    @objc var IsContentRetentionKey: Bool {
        get { return bool(forKey: "IsContentRetentionKey") }
        set { set(newValue, forKey: "IsContentRetentionKey") }
    }
    @objc var IsShowWindowShadowKey: Bool {
        get { return bool(forKey: "IsShowWindowShadowKey") }
        set { set(newValue, forKey: "IsShowWindowShadowKey") }
    }
    @objc var IsWithAnimationKey: Bool {
        get { return bool(forKey: "IsWithAnimationKey") }
        set { set(newValue, forKey: "IsWithAnimationKey") }
    }
    @objc var ContentStyleKey: Int {
        get { return integer(forKey: "ContentStyleKey") }
        set { set(newValue, forKey: "ContentStyleKey") }
    }
    @objc var PortraitCornerKey: Int {
        get { return integer(forKey: "PortraitCornerKey") }
        set { set(newValue, forKey: "PortraitCornerKey") }
    }
    @objc var LandscapeAutoScrollKey: Bool {
        get { return bool(forKey: "LandscapeAutoScrollKey") }
        set { set(newValue, forKey: "LandscapeAutoScrollKey") }
    }
    @objc var PortraitMaxHeightKey: Double {
        get { return double(forKey: "PortraitMaxHeightKey") }
        set { set(newValue, forKey: "PortraitMaxHeightKey") }
    }
    @objc var LandscapeMaxWidthKey: Double {
        get { return double(forKey: "LandscapeMaxWidthKey") }
        set { set(newValue, forKey: "LandscapeMaxWidthKey") }
    }
    @objc var FontSizeKey: Double {
        get { return double(forKey: "FontSizeKey") }
        set { set(newValue, forKey: "FontSizeKey") }
    }
    @objc var FontRateKey: Double {
        get { return double(forKey: "FontRateKey") }
        set { set(newValue, forKey: "FontRateKey") }
    }
    @objc var TheColorSchemeKey: Int {
        get { return integer(forKey: "TheColorSchemeKey") }
        set { set(newValue, forKey: "TheColorSchemeKey") }
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
}

var subscriptions = Set<AnyCancellable>()

func combineWindows() {
    UserDefaults.standard
        .publisher(for: \.CropperStyleKey)
        .handleEvents(receiveOutput: { cropperStyle in
            syncCropperView(from: CropperStyle(rawValue: cropperStyle)!)
            myPrint("did syncCropperView")
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.IsShowWindowShadowKey)
        .handleEvents(receiveOutput: { isShowWindowShadow in
            syncContentWindowShadow(from: isShowWindowShadow)
            myPrint("did syncContentWindowShadow")
        })
        .sink { _ in }
        .store(in: &subscriptions)
}

func autoSaveSlotSettings() {
    combineSlot(\.TRTextRecognitionLevelKey, \.tRTextRecognitionLevel, TRTextRecognitionLevelKey)
    combineSlot(\.TRMinimumTextHeightKey, \.tRMinimumTextHeight, TRMinimumTextHeightKey)
    combineSlot(\.MaximumFrameRateKey, \.maximumFrameRate, MaximumFrameRateKey)
    combineSlot(\.UseEntryModeKey, \.useEntryMode, UseEntryModeKey)
    combineSlot(\.IsShowPhrasesKey, \.isShowPhrases, IsShowPhrasesKey)
    combineSlot(\.CropperStyleKey, \.cropperStyle, CropperStyleKey)
    combineSlot(\.IsDropTitleWordKey, \.isDropTitleWord, IsDropTitleWordKey)
    combineSlot(\.IsAddLineBreakKey, \.isAddLineBreak, IsAddLineBreakKey)
    combineSlot(\.IsAddSpaceKey, \.isAddSpace, IsAddSpaceKey)
    combineSlot(\.IsDropFirstTitleWordInTranslationKey, \.isDropFirstTitleWordInTranslation, IsDropFirstTitleWordInTranslationKey)
    combineSlot(\.IsJoinTranslationLinesKey, \.isJoinTranslationLines, IsJoinTranslationLinesKey)
    combineSlot(\.ChineseCharacterConvertModeKey, \.chineseCharacterConvertMode, ChineseCharacterConvertModeKey)
    combineSlot(\.IsContentRetentionKey, \.isContentRetention, IsContentRetentionKey)
    combineSlot(\.IsShowWindowShadowKey, \.isShowWindowShadow, IsShowWindowShadowKey)
    combineSlot(\.IsWithAnimationKey, \.isWithAnimation, IsWithAnimationKey)
    combineSlot(\.ContentStyleKey, \.contentStyle, ContentStyleKey)
    combineSlot(\.PortraitCornerKey, \.portraitCorner, PortraitCornerKey)
    combineSlot(\.LandscapeAutoScrollKey, \.landscapeAutoScroll, LandscapeAutoScrollKey)
    combineSlot(\.PortraitMaxHeightKey, \.portraitMaxHeight, PortraitMaxHeightKey)
    combineSlot(\.LandscapeMaxWidthKey, \.landscapeMaxWidth, LandscapeMaxWidthKey)
    combineSlot(\.FontSizeKey, \.fontSize, FontSizeKey)
    combineSlot(\.FontRateKey, \.fontRate, FontRateKey)
    combineSlot(\.TheColorSchemeKey, \.theColorScheme, TheColorSchemeKey)
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
}

func combineSlot<T>(
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
                    myPrint("did save slot \(keypathName)")
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
}
