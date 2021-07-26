//
//  UserDefaultSettings.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import Foundation
import Cocoa

func initUserDefaultIfEmpty() {
    if UserDefaults.standard.object(forKey: IsShowPhrasesKey) == nil {
        UserDefaults.standard.set(true, forKey: IsShowPhrasesKey)
    }
    if UserDefaults.standard.object(forKey: IsAddLineBreakKey) == nil {
        UserDefaults.standard.set(true, forKey: IsAddLineBreakKey)
    }
    if UserDefaults.standard.object(forKey: IsShowCurrentKnownKey) == nil {
        UserDefaults.standard.set(false, forKey: IsShowCurrentKnownKey)
    }
    if UserDefaults.standard.object(forKey: FontRateKey) == nil {
        UserDefaults.standard.set(0.6, forKey: FontRateKey)
    }
    
    if UserDefaults.standard.object(forKey: TRTextRecognitionLevelKey) == nil {
        UserDefaults.standard.set(1, forKey: TRTextRecognitionLevelKey) // 1 fast, 0 accurate
    }
    if UserDefaults.standard.object(forKey: TRMinimumTextHeightKey) == nil {
        UserDefaults.standard.set(systemDefaultMinimumTextHeight, forKey: TRMinimumTextHeightKey)
    }
    if UserDefaults.standard.object(forKey: IsWithAnimationKey) == nil {
        UserDefaults.standard.set(true, forKey: IsWithAnimationKey)
    }
    
    if UserDefaults.standard.object(forKey: CropperStyleKey) == nil {
        UserDefaults.standard.set(CropperStyle.closed.rawValue, forKey: CropperStyleKey)
    }
    if UserDefaults.standard.object(forKey: ContentStyleKey) == nil {
        UserDefaults.standard.set(ContentStyle.portrait.rawValue, forKey: ContentStyleKey)
    }
    
    if UserDefaults.standard.object(forKey: IsShowWindowShadowKey) == nil {
        UserDefaults.standard.set(false, forKey: IsShowWindowShadowKey)
    }
            
//    if UserDefaults.standard.object(forKey: "visualConfig.fontSizeOfLandscape") == nil { // Notice: don't set it Some(0) by mistake
//        UserDefaults.standard.set(defaultFontSizeOfLandscape, forKey: "visualConfig.fontSizeOfLandscape")
//    }
//    if UserDefaults.standard.object(forKey: "visualConfig.fontSizeOfPortrait") == nil {
//        UserDefaults.standard.set(defaultFontSizeOfPortrait, forKey: "visualConfig.fontSizeOfPortrait")
//    }
//    if UserDefaults.standard.object(forKey: "visualConfig.fontName") == nil {
//        UserDefaults.standard.set(NSFont.systemFont(ofSize: 0.0).fontName, forKey: "visualConfig.fontName")
//    }
//    if UserDefaults.standard.object(forKey: "visualConfig.colorOfLandscape") == nil {
//        UserDefaults.standard.set(colorToData(NSColor.orange)!, forKey: "visualConfig.colorOfLandscape")
//    }
//    if UserDefaults.standard.object(forKey: "visualConfig.colorOfPortrait") == nil {
//        UserDefaults.standard.set(colorToData(NSColor.green)!, forKey: "visualConfig.colorOfPortrait")
//    }
}

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
    
//    UserDefaults.standard.set(defaultFontSizeOfLandscape, forKey: "visualConfig.fontSizeOfLandscape")
//    UserDefaults.standard.set(defaultFontSizeOfPortrait, forKey: "visualConfig.fontSizeOfPortrait")
//    UserDefaults.standard.set(colorToData(NSColor.orange)!, forKey: "visualConfig.colorOfLandscape")
//    UserDefaults.standard.set(colorToData(NSColor.green)!, forKey: "visualConfig.colorOfPortrait")
//    UserDefaults.standard.set(NSFont.systemFont(ofSize: 0.0).fontName, forKey: "visualConfig.fontName")
//    visualConfig.fontSizeOfLandscape = CGFloat(defaultFontSizeOfLandscape)
//    visualConfig.fontSizeOfPortrait = CGFloat(defaultFontSizeOfPortrait)
//    visualConfig.colorOfLandscape = .orange
//    visualConfig.colorOfPortrait = .green
//    visualConfig.fontName = NSFont.systemFont(ofSize: 0.0).fontName
//
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

func saveAllUserDefaults() {
//    UserDefaults.standard.set(Double(visualConfig.fontSizeOfLandscape), forKey: "visualConfig.fontSizeOfLandscape")
//    UserDefaults.standard.set(Double(visualConfig.fontSizeOfPortrait), forKey: "visualConfig.fontSizeOfPortrait")
//    UserDefaults.standard.set(colorToData(visualConfig.colorOfLandscape)!, forKey: "visualConfig.colorOfLandscape")
//    UserDefaults.standard.set(colorToData(visualConfig.colorOfPortrait)!, forKey: "visualConfig.colorOfPortrait")
//    UserDefaults.standard.set(visualConfig.fontName, forKey: "visualConfig.fontName")
}

// UserDefault keys:
let TRTextRecognitionLevelKey = "TRTextRecognitionLevelKey"
let TRMinimumTextHeightKey = "TRMinimumTextHeightKey"

let IsWithAnimationKey = "IsWithAnimationKey"

let IsShowPhrasesKey = "IsShowPhrasesKey"
let IsAddLineBreakKey = "IsAddLineBreakKey"
let IsShowCurrentKnownKey = "IsShowCurrentKnownKey"
let FontRateKey = "FontRateKey"

let CropperStyleKey = "CropperStyleKey"
let ContentStyleKey = "ContentStyleKey"

let IsShowWindowShadowKey = "IsShowWindowShadowKey"

let ContentBackgroundDisplayKey = "ContentBackgroundDisplayKey"

let ContentBackGroundVisualEffectMaterialKey = "ContentBackGroundVisualEffectMaterialKey"
let ContentBackGroundVisualEffectBlendingModeKey = "ContentBackGroundVisualEffectBlendingModeKey"
let ContentBackGroundVisualEffectIsEmphasizedKey = "ContentBackGroundVisualEffectIsEmphasizedKey"
let ContentBackGroundVisualEffectStateKey = "ContentBackGroundVisualEffectStateKey"
