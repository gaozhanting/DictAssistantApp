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

enum TheColorScheme: Int, Codable {
    case light = 0
    case dark = 1
    case system = 2
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


// in slot defaults
// !! Need sync with var defaultSettings in SlotsSettingsView
private let defaultSlotKV: [String: Any] = [
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
    @objc var CropperStyleKey: Int {
        get { return integer(forKey: "CropperStyleKey") }
        set { set(newValue, forKey: "CropperStyleKey") }
    }
    
    @objc var IsShowWindowShadowKey: Bool {
        get { return bool(forKey: "IsShowWindowShadowKey") }
        set { set(newValue, forKey: "IsShowWindowShadowKey") }
    }
    
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
//    @objc var CropperStyleKey: Int {
//        get { return integer(forKey: "CropperStyleKey") }
//        set { set(newValue, forKey: "CropperStyleKey") }
//    }
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
//    @objc var IsShowWindowShadowKey: Bool {
//        get { return bool(forKey: "IsShowWindowShadowKey") }
//        set { set(newValue, forKey: "IsShowWindowShadowKey") }
//    }
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
func combineSomeUserDefaults() {
    UserDefaults.standard
        .publisher(for: \.CropperStyleKey)
        .handleEvents(receiveOutput: { cropperStyle in
            myPrint("did combine cropperStyle")
            syncCropperView(from: CropperStyle(rawValue: cropperStyle)!)
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.IsShowWindowShadowKey)
        .handleEvents(receiveOutput: { isShowWindowShadow in
            myPrint("did combine isShowWindowShadow")
            syncContentWindowShadow(from: isShowWindowShadow)
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.TRTextRecognitionLevelKey, \.tRTextRecognitionLevel, TRTextRecognitionLevelKey)
    UserDefaults.standard
        .publisher(for: \.TRTextRecognitionLevelKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.tRTextRecognitionLevel != newValue {
                        slot.tRTextRecognitionLevel = Int64(newValue)
                        saveContext()
                        myPrint("did save slot tRTextRecognitionLevel")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.TRMinimumTextHeightKey, \.tRMinimumTextHeight, TRMinimumTextHeightKey)
    UserDefaults.standard
        .publisher(for: \.TRMinimumTextHeightKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.tRMinimumTextHeight != newValue {
                        slot.tRMinimumTextHeight = newValue
                        saveContext()
                        myPrint("did save slot tRMinimumTextHeight")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.MaximumFrameRateKey, \.maximumFrameRate, MaximumFrameRateKey)
    UserDefaults.standard
        .publisher(for: \.MaximumFrameRateKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.maximumFrameRate != newValue {
                        slot.maximumFrameRate = newValue
                        saveContext()
                        myPrint("did save slot MaximumFrameRateKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.UseEntryModeKey, \.useEntryMode, UseEntryModeKey)
    UserDefaults.standard
        .publisher(for: \.UseEntryModeKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.useEntryMode != newValue {
                        slot.useEntryMode = Int64(newValue)
                        saveContext()
                        myPrint("did save slot UseEntryModeKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.IsShowPhrasesKey, \.isShowPhrases, IsShowPhrasesKey)
    UserDefaults.standard
        .publisher(for: \.IsShowPhrasesKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.isShowPhrases != newValue {
                        slot.isShowPhrases = newValue
                        saveContext()
                        myPrint("did save slot IsShowPhrasesKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.CropperStyleKey, \.cropperStyle, CropperStyleKey)
    UserDefaults.standard
        .publisher(for: \.CropperStyleKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.cropperStyle != newValue {
                        slot.cropperStyle = Int64(newValue)
                        saveContext()
                        myPrint("did save slot CropperStyleKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.IsDropTitleWordKey, \.isDropTitleWord, IsDropTitleWordKey)
    UserDefaults.standard
        .publisher(for: \.IsDropTitleWordKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.isDropTitleWord != newValue {
                        slot.isDropTitleWord = newValue
                        saveContext()
                        myPrint("did save slot IsDropTitleWordKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.IsAddLineBreakKey, \.isAddLineBreak, IsAddLineBreakKey)
    UserDefaults.standard
        .publisher(for: \.IsAddLineBreakKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.isAddLineBreak != newValue {
                        slot.isAddLineBreak = newValue
                        saveContext()
                        myPrint("did save slot IsAddLineBreakKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.IsDropFirstTitleWordInTranslationKey, \.isDropFirstTitleWordInTranslation, IsDropFirstTitleWordInTranslationKey)
    UserDefaults.standard
        .publisher(for: \.IsDropFirstTitleWordInTranslationKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.isDropFirstTitleWordInTranslation != newValue {
                        slot.isDropFirstTitleWordInTranslation = newValue
                        saveContext()
                        myPrint("did save slot IsDropFirstTitleWordInTranslationKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.IsJoinTranslationLinesKey, \.isJoinTranslationLines, IsJoinTranslationLinesKey)
    UserDefaults.standard
        .publisher(for: \.IsJoinTranslationLinesKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.isJoinTranslationLines != newValue {
                        slot.isJoinTranslationLines = newValue
                        saveContext()
                        myPrint("did save slot IsJoinTranslationLinesKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.ChineseCharacterConvertModeKey, \.chineseCharacterConvertMode, ChineseCharacterConvertModeKey)
    UserDefaults.standard
        .publisher(for: \.ChineseCharacterConvertModeKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.chineseCharacterConvertMode != newValue {
                        slot.chineseCharacterConvertMode = Int64(newValue)
                        saveContext()
                        myPrint("did save slot ChineseCharacterConvertModeKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.IsContentRetentionKey, \.isContentRetention, IsContentRetentionKey)
    UserDefaults.standard
        .publisher(for: \.IsContentRetentionKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.isContentRetention != newValue {
                        slot.isContentRetention = newValue
                        saveContext()
                        myPrint("did save slot IsContentRetentionKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.IsShowWindowShadowKey, \.isShowWindowShadow, IsShowWindowShadowKey)
    UserDefaults.standard
        .publisher(for: \.IsShowWindowShadowKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.isShowWindowShadow != newValue {
                        slot.isShowWindowShadow = newValue
                        saveContext()
                        myPrint("did save slot IsShowWindowShadowKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.IsWithAnimationKey, \.isWithAnimation, IsWithAnimationKey)
    UserDefaults.standard
        .publisher(for: \.IsWithAnimationKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.isWithAnimation != newValue {
                        slot.isWithAnimation = newValue
                        saveContext()
                        myPrint("did save slot IsWithAnimationKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.ContentStyleKey, \.contentStyle, ContentStyleKey)
    UserDefaults.standard
        .publisher(for: \.ContentStyleKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.contentStyle != newValue {
                        slot.contentStyle = Int64(newValue)
                        saveContext()
                        myPrint("did save slot ContentStyleKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.PortraitCornerKey, \.portraitCorner, PortraitCornerKey)
    UserDefaults.standard
        .publisher(for: \.PortraitCornerKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.portraitCorner != newValue {
                        slot.portraitCorner = Int64(newValue)
                        saveContext()
                        myPrint("did save slot PortraitCornerKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.LandscapeAutoScrollKey, \.landscapeAutoScroll, LandscapeAutoScrollKey)
    UserDefaults.standard
        .publisher(for: \.LandscapeAutoScrollKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.landscapeAutoScroll != newValue {
                        slot.landscapeAutoScroll = newValue
                        saveContext()
                        myPrint("did save slot LandscapeAutoScrollKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.PortraitMaxHeightKey, \.portraitMaxHeight, PortraitMaxHeightKey)
    UserDefaults.standard
        .publisher(for: \.PortraitMaxHeightKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.portraitMaxHeight != newValue {
                        slot.portraitMaxHeight = newValue
                        saveContext()
                        myPrint("did save slot PortraitMaxHeightKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.LandscapeMaxWidthKey, \.landscapeMaxWidth, LandscapeMaxWidthKey)
    UserDefaults.standard
        .publisher(for: \.LandscapeMaxWidthKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.landscapeMaxWidth != newValue {
                        slot.landscapeMaxWidth = newValue
                        saveContext()
                        myPrint("did save slot LandscapeMaxWidthKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.FontSizeKey, \.fontSize, FontSizeKey)
    UserDefaults.standard
        .publisher(for: \.FontSizeKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.fontSize != newValue {
                        slot.fontSize = newValue
                        saveContext()
                        myPrint("did save slot FontSizeKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.FontRateKey, \.fontRate, FontRateKey)
    UserDefaults.standard
        .publisher(for: \.FontRateKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.fontRate != newValue {
                        slot.fontRate = newValue
                        saveContext()
                        myPrint("did save slot FontRateKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.TheColorSchemeKey, \.theColorScheme, TheColorSchemeKey)
    UserDefaults.standard
        .publisher(for: \.TheColorSchemeKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.theColorScheme != newValue {
                        slot.theColorScheme = Int64(newValue)
                        saveContext()
                        myPrint("did save slot TheColorSchemeKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.WordColorKey, \.wordColor, WordColorKey)
    UserDefaults.standard
        .publisher(for: \.WordColorKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.wordColor != newValue {
                        slot.wordColor = newValue
                        saveContext()
                        myPrint("did save slot WordColorKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.TransColorKey, \.transColor, TransColorKey)
    UserDefaults.standard
        .publisher(for: \.TransColorKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.transColor != newValue {
                        slot.transColor = newValue
                        saveContext()
                        myPrint("did save slot TransColorKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.BackgroundColorKey, \.backgroundColor, BackgroundColorKey)
    UserDefaults.standard
        .publisher(for: \.BackgroundColorKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.backgroundColor != newValue {
                        slot.backgroundColor = newValue
                        saveContext()
                        myPrint("did save slot BackgroundColorKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.TextShadowToggleKey, \.textShadowToggle, TextShadowToggleKey)
    UserDefaults.standard
        .publisher(for: \.TextShadowToggleKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.textShadowToggle != newValue {
                        slot.textShadowToggle = newValue
                        saveContext()
                        myPrint("did save slot TextShadowToggleKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.ShadowColorKey, \.shadowColor, ShadowColorKey)
    UserDefaults.standard
        .publisher(for: \.ShadowColorKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.shadowColor != newValue {
                        slot.shadowColor = newValue
                        saveContext()
                        myPrint("did save slot ShadowColorKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.ShadowRadiusKey, \.shadowRadius, ShadowRadiusKey)
    UserDefaults.standard
        .publisher(for: \.ShadowRadiusKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.shadowRadius != newValue {
                        slot.shadowRadius = newValue
                        saveContext()
                        myPrint("did save slot ShadowRadiusKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.ShadowXOffSetKey, \.shadowXOffset, ShadowXOffSetKey)
    UserDefaults.standard
        .publisher(for: \.ShadowXOffSetKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.shadowXOffset != newValue {
                        slot.shadowXOffset = newValue
                        saveContext()
                        myPrint("did save slot ShadowXOffSetKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.ShadowYOffSetKey, \.shadowYOffset, ShadowYOffSetKey)
    UserDefaults.standard
        .publisher(for: \.ShadowYOffSetKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.shadowYOffset != newValue {
                        slot.shadowYOffset = newValue
                        saveContext()
                        myPrint("did save slot ShadowYOffSetKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.UseContentBackgroundColorKey, \.useContentBackgroundColor, UseContentBackgroundColorKey)
    UserDefaults.standard
        .publisher(for: \.UseContentBackgroundColorKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.useContentBackgroundColor != newValue {
                        slot.useContentBackgroundColor = newValue
                        saveContext()
                        myPrint("did save slot UseContentBackgroundColorKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.UseContentBackgroundVisualEffectKey, \.useContentBackgroundVisualEffect, UseContentBackgroundVisualEffectKey)
    UserDefaults.standard
        .publisher(for: \.UseContentBackgroundVisualEffectKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.useContentBackgroundVisualEffect != newValue {
                        slot.useContentBackgroundVisualEffect = newValue
                        saveContext()
                        myPrint("did save slot UseContentBackgroundVisualEffectKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
//    combineSlot(\.ContentBackGroundVisualEffectMaterialKey, \.contentBackGroundVisualEffectMaterial, ContentBackGroundVisualEffectMaterialKey)
    UserDefaults.standard
        .publisher(for: \.ContentBackGroundVisualEffectMaterialKey)
        .handleEvents(receiveOutput: { newValue in
            let slots = getAllSlots()
            for slot in slots {
                if slot.isSelected {
                    if slot.contentBackGroundVisualEffectMaterial != newValue {
                        slot.contentBackGroundVisualEffectMaterial = Int64(newValue)
                        saveContext()
                        myPrint("did save slot ContentBackGroundVisualEffectMaterialKey")
                        return
                    }
                }
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
}

//private func combineSlot<T1, T2>(
//    _ keyPathUserDefaultValue: KeyPath<UserDefaults, T1>,
//    _ keyPathCoreDataValue: WritableKeyPath<Slot, T2>,
//    _ keyPathName: String
//) {
//    UserDefaults.standard
//        .publisher(for: keyPathUserDefaultValue)
//        .handleEvents(receiveOutput: { newValue in
//            let slots = getAllSlots()
//            for var slot in slots {
//                if slot.isSelected {
//                    if slot[keyPath: keyPathCoreDataValue] != newValue {
//                    slot[keyPath: keyPathCoreDataValue] = newValue as! T1
//                        saveContext()
//                        myPrint("did save slot \(keyPathName)")
//                        return
////                    }
//                }
//            }
//        })
//        .sink { _ in }
//        .store(in: &subscriptions)
//}

//private func combineSlot<T: Comparable>(
//    _ keyPathUserDefaultValue: KeyPath<UserDefaults, T>,
//    _ keyPathCoreDataValue: WritableKeyPath<Slot, T>,
//    _ keyPathName: String
//) {
//    UserDefaults.standard
//        .publisher(for: keyPathUserDefaultValue)
//        .handleEvents(receiveOutput: { newValue in
//            let slots = getAllSlots()
//            for var slot in slots {
//                if slot.isSelected {
//                    if slot[keyPath: keyPathCoreDataValue] != newValue {
//                        slot[keyPath: keyPathCoreDataValue] = newValue
//                        saveContext()
//                        myPrint("did save slot \(keyPathName)")
//                        return
//                    }
//                }
//            }
//        })
//        .sink { _ in }
//        .store(in: &subscriptions)
//}

//private func update<T: Comparable>(_ keyPathValue: WritableKeyPath<Slot, T>, _ newValue: T) {
//    let slots = getAllSlots()
//    for var slot in slots {
//        if slot.isSelected {
//            if slot[keyPath: keyPathValue] != newValue {
//                slot[keyPath: keyPathValue] = newValue
//                saveContext()
//                myPrint("did save slot \(String(keyPathValue))")
//                return
//            }
//        }
//    }
//}

//private func updateSelectedSlot(newValue: Double) {
//    let slots = getAllSlots()
//    for slot in slots {
//        if slot.isSelected {
//            if slot.tRMinimumTextHeight != newValue {
//                slot.tRMinimumTextHeight = newValue
//                saveContext()
//                myPrint("did save slot (tRMinimumTextHeight)")
//                return
//            }
//        }
//    }
//}
