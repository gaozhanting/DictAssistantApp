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

let defaultFontName = NSFont.systemFont(ofSize: 0).fontName // returns ".AppleSystemUIFont"
let defaultNSFont = NSFont(name: defaultFontName, size: 18.0)!
let FontNameKey = "FontNameKey" // not in slot for basic consistence of visual

let ShowToastToggleKey = "ShowToastToggleKey" // not in slot for basic consistence of an auxiliary extra trick

// general
let TRTextRecognitionLevelKey = "TRTextRecognitionLevelKey"
let TRMinimumTextHeightKey = "TRMinimumTextHeightKey"
let MaximumFrameRateKey = "MaximumFrameRateKey"

// visual
let IsShowPhrasesKey = "IsShowPhrasesKey"

let CropperStyleKey = "CropperStyleKey"

let IsDropTitleWordKey = "IsDropTitleWordKey"
let IsAddLineBreakKey = "IsAddLineBreakKey"
let IsAddSpaceKey = "IsAddSpaceKey"
let IsDropFirstTitleWordInTranslationKey = "IsDropFirstTitleWordInTranslationKey"
let IsJoinTranslationLinesKey = "IsJoinTranslationLinesKey"

let IsShowWindowShadowKey = "IsShowWindowShadowKey"

let IsWithAnimationKey = "IsWithAnimationKey"

let ContentStyleKey = "ContentStyleKey"
let PortraitCornerKey = "PortraitCornerKey"
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

let ContentBackgroundVisualEffectKey = "ContentBackgroundVisualEffectKey"
let ContentBackGroundVisualEffectMaterialKey = "ContentBackGroundVisualEffectMaterialKey"

// in slot defaults
fileprivate let defaultSlotKV: [String: Any] = [
    TRTextRecognitionLevelKey: VNRequestTextRecognitionLevel.fast.rawValue,
    TRMinimumTextHeightKey: systemDefaultMinimumTextHeight,
    MaximumFrameRateKey: 4,
    
    IsShowPhrasesKey: true,
    
    CropperStyleKey: CropperStyle.closed.rawValue,
    
    IsDropTitleWordKey: false,
    IsAddLineBreakKey: true,
    IsAddSpaceKey: false,
    IsDropFirstTitleWordInTranslationKey: true,
    IsJoinTranslationLinesKey: false,
    
    IsShowWindowShadowKey: true,
    
    IsWithAnimationKey: true,
    
    ContentStyleKey: ContentStyle.portrait.rawValue,
    PortraitCornerKey: PortraitCorner.topTrailing.rawValue,
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
    
    ContentBackgroundVisualEffectKey: false,
    ContentBackGroundVisualEffectMaterialKey: NSVisualEffectView.Material.titlebar.rawValue,
]

// all defaults
fileprivate let defaultKV: [String: Any] = defaultSlotKV.merging([
    IsShowCurrentKnownKey: false,
    IsShowCurrentKnownButWithOpacity0Key: false,
    FontNameKey: defaultFontName,
    ShowToastToggleKey: true
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
        get {
            return integer(forKey: "CropperStyleKey")
        }
        set {
            set(newValue, forKey: "CropperStyleKey")
        }
    }
}

extension UserDefaults {
    @objc var IsShowWindowShadowKey: Bool {
        get {
            return bool(forKey: "IsShowWindowShadowKey")
        }
        set {
            set(newValue, forKey: "IsShowWindowShadowKey")
        }
    }
}

var subscriptions = Set<AnyCancellable>()
func combineSomeUserDefaults() {
    UserDefaults.standard
        .publisher(for: \.CropperStyleKey)
        .handleEvents(receiveOutput: { cropperStyle in
            if statusData.isPlaying {
                syncCropperView(from: CropperStyle(rawValue: cropperStyle)!)
            }
        })
        .sink { _ in }
        .store(in: &subscriptions)
    
    UserDefaults.standard
        .publisher(for: \.IsShowWindowShadowKey)
        .handleEvents(receiveOutput: { isShowWindowShadow in
            syncContentWindowShadow(from: isShowWindowShadow)
        })
        .sink { _ in }
        .store(in: &subscriptions)
}

// Slots
let SelectedSlotKey = "SelectedSlotKey"

let BlueSettingsKey = "BlueSettingsKey"
let PurpleSettingsKey = "PurpleSettingsKey"
let PinkSettingsKey = "PinkSettingsKey"
let RedSettingsKey = "RedSettingsKey"
let OrangeSettingsKey = "OrangeSettingsKey"
let YellowSettingsKey = "YellowSettingsKey"
let GreenSettingsKey = "GreenSettingsKey"
let GraySettingsKey = "GraySettingsKey"

let BlueLabelKey = "BlueLabelKey"
let PurpleLabelKey = "PurpleLabelKey"
let PinkLabelKey = "PinkLabelKey"
let RedLabelKey = "RedLabelKey"
let OrangeLabelKey = "OrangeLabelKey"
let YellowLabelKey = "YelloLabelKey"
let GreenLabelKey = "GreenLabelKey"
let GrayLabelKey = "GrayLabelKey"
