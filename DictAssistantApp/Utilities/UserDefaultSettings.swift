//
//  UserDefaultSettings.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import Foundation
import Cocoa

func resetUserDefaults() {
    UserDefaults.standard.set(true, forKey: IsShowPhrasesKey)
    UserDefaults.standard.set(true, forKey: IsAddLineBreakKey)
    UserDefaults.standard.set(false, forKey: IsShowCurrentKnownKey)
    UserDefaults.standard.set(0.6, forKey: FontRateKey)
    
    UserDefaults.standard.set(1, forKey: TRTextRecognitionLevelKey)
    UserDefaults.standard.set(systemDefaultMinimumTextHeight, forKey: TRMinimumTextHeightKey)
    UserDefaults.standard.set(true, forKey: IsWithAnimationKey)
    
    UserDefaults.standard.set(CropperStyle.closed.rawValue, forKey: CropperStyleKey)
    UserDefaults.standard.set(ContentStyle.portrait.rawValue, forKey: ContentStyleKey)
    UserDefaults.standard.set(false, forKey: IsShowWindowShadowKey)
    
//    landscapeWordsPanel.setFrame(
//        NSRect(x: 100, y: 100, width: 600, height: 200),
//        display: true,
//        animate: true
//    )
//    portraitWordsPanel.setFrame(
//        NSRect(x: 100, y: 100, width: 200, height: 600),
//        display: true,
//        animate: true
//    )
//    cropperWindow.setFrame(
//        NSRect(x: 300, y: 300, width: 600, height: 200),
//        display: true,
//        animate: true
//    )
}

// UserDefault keys:
let TRTextRecognitionLevelKey = "TRTextRecognitionLevelKey"
let TRMinimumTextHeightKey = "TRMinimumTextHeightKey"

let IsWithAnimationKey = "IsWithAnimationKey"

let IsShowPhrasesKey = "IsShowPhrasesKey"
let IsAddLineBreakKey = "IsAddLineBreakKey"
let IsShowCurrentKnownKey = "IsShowCurrentKnownKey"

let CropperStyleKey = "CropperStyleKey"
let ContentStyleKey = "ContentStyleKey"

let IsShowWindowShadowKey = "IsShowWindowShadowKey"

let ContentBackgroundVisualEffectKey = "ContentBackgroundVisualEffectKey"

let ContentBackGroundVisualEffectMaterialKey = "ContentBackGroundVisualEffectMaterialKey"
let ContentBackGroundVisualEffectBlendingModeKey = "ContentBackGroundVisualEffectBlendingModeKey"
let ContentBackGroundVisualEffectIsEmphasizedKey = "ContentBackGroundVisualEffectIsEmphasizedKey"
let ContentBackGroundVisualEffectStateKey = "ContentBackGroundVisualEffectStateKey"

let WordColorKey = "WordColorKey"
let TransColorKey = "TransColorKey"
let BackgroundColorKey = "BackgroundColorKey"

let PortraitCornerKey = "PortraitCornerKey"

let ShowToastToggleKey = "ShowToastToggleKey"

let FontKey = "FontKey"
let FontRateKey = "FontRateKey"

let ShadowColorKey = "ShadowColorKey"
let ShadowRadiusKey = "ShadowRadiusKey"
let ShadowXOffSetKey = "ShadowXOffSetKey"
let ShadowYOffSetKey = "ShadowYOffSetKey"

let TextShadowToggleKey = "TextShadowToggleKey"

let PortraitMaxHeightKey = "PortraitMaxHeightKey"
let LandscapeMaxWidthKey = "LandscapeMaxWidthKey"

let SpeakWordToggleKey = "SpeakWordToggleKey"

let TheColorSchemeKey = "TheColorSchemeKey"
