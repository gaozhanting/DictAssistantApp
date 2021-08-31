//
//  UserDefaultSettings.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import Foundation
import Cocoa
import Vision

// UserDefault keys:
let TRTextRecognitionLevelKey = "TRTextRecognitionLevelKey"
let TRMinimumTextHeightKey = "TRMinimumTextHeightKey"

let MaximumFrameRateKey = "MaximumFrameRateKey"

let IsShowCurrentKnownKey = "IsShowCurrentKnownKey"
let IsShowPhrasesKey = "IsShowPhrasesKey"
let IsAddLineBreakKey = "IsAddLineBreakKey"
let IsAddSpaceKey = "IsAddSpaceKey" // not in slot
let isDropFirstTitleWordInTranslationKey = "isDropFirstTitleWordInTranslationKey" // not in slot
let IsDropTitleWordKey = "IsDropTitleWordKey" // not in slot
let isJoinTranslationLinesKey = "isJoinTranslationLinesKey" // not in slot

let IsShowWindowShadowKey = "IsShowWindowShadowKey"

let IsWithAnimationKey = "IsWithAnimationKey"

let CropperStyleKey = "CropperStyleKey"
let ContentStyleKey = "ContentStyleKey"

let ContentBackgroundVisualEffectKey = "ContentBackgroundVisualEffectKey"

let ContentBackGroundVisualEffectMaterialKey = "ContentBackGroundVisualEffectMaterialKey"

let WordColorKey = "WordColorKey"
let TransColorKey = "TransColorKey"
let BackgroundColorKey = "BackgroundColorKey"

let PortraitCornerKey = "PortraitCornerKey"

let ShowToastToggleKey = "ShowToastToggleKey"

let defaultFontName = NSFont.systemFont(ofSize: 0).fontName // returns ".AppleSystemUIFont"
let defaultNSFont = NSFont(name: defaultFontName, size: 18.0)!
let FontNameKey = "FontNameKey"
let FontSizeKey = "FontSizeKey"
let FontRateKey = "FontRateKey"

let ShadowColorKey = "ShadowColorKey"
let ShadowRadiusKey = "ShadowRadiusKey"
let ShadowXOffSetKey = "ShadowXOffSetKey"
let ShadowYOffSetKey = "ShadowYOffSetKey"

let TextShadowToggleKey = "TextShadowToggleKey"

let PortraitMaxHeightKey = "PortraitMaxHeightKey"
let LandscapeMaxWidthKey = "LandscapeMaxWidthKey"

let TheColorSchemeKey = "TheColorSchemeKey"

// defaults
let defaultKV: [String: Any] = [
    TRTextRecognitionLevelKey: VNRequestTextRecognitionLevel.fast.rawValue,
    MaximumFrameRateKey: 4,
    IsWithAnimationKey: true,
    IsShowPhrasesKey: true,
    IsAddLineBreakKey: true,
    IsShowCurrentKnownKey: false,
    CropperStyleKey: CropperStyle.closed.rawValue,
    ContentStyleKey: ContentStyle.portrait.rawValue,
    IsShowWindowShadowKey: false,
    ContentBackgroundVisualEffectKey: false,
    ContentBackGroundVisualEffectMaterialKey: NSVisualEffectView.Material.titlebar.rawValue,
    WordColorKey: colorToData(NSColor.labelColor.withAlphaComponent(0.3))!,
    TransColorKey: colorToData(NSColor.highlightColor)!,
    BackgroundColorKey: colorToData(NSColor.clear)!,
    PortraitCornerKey: PortraitCorner.topTrailing.rawValue,
    ShowToastToggleKey: true,
    FontNameKey: defaultFontName,
    FontSizeKey: 18.0,
    FontRateKey: 0.6,
    ShadowColorKey: colorToData(NSColor.labelColor)!,
    ShadowRadiusKey: 3,
    ShadowXOffSetKey: 0.0,
    ShadowYOffSetKey: 2.0,
    TextShadowToggleKey: false,
    PortraitMaxHeightKey: 200.0,
    LandscapeMaxWidthKey: 260.0,
    TheColorSchemeKey: TheColorScheme.system.rawValue,
]

func initUserSettings() {
    for (key, value) in defaultKV {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.setValue(value, forKey: key)
        }
    }
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
