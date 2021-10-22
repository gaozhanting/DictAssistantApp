//
//  SlotsSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/8/6.
//

import SwiftUI
import Preferences
import Vision

struct Settings: Codable {
    // general and main settings for a slot
    let tRTextRecognitionLevel: Int
    let tRMinimumTextHeight: Double
    let maximumFrameRate: Double
    
    let useEntryMode: UseEntryMode
    
    // visual settings for a slot
    let isShowPhrases: Bool
    
    let cropperStyle: CropperStyle

    // -- fine-turning the display of the returned translation text from different dictionaries
    let isDropTitleWord: Bool
    let isAddLineBreak: Bool
    let isAddSpace: Bool
    let isDropFirstTitleWordInTranslation: Bool
    let isJoinTranslationLines: Bool
    let chineseCharacterConvertMode: ChineseCharacterConvertMode
    
    let isContentRetention: Bool
    
    let isShowWindowShadow: Bool
    
    let isWithAnimation: Bool
    
    // -- content style & max width & max height
    let contentStyle: ContentStyle
    let portraitCorner: PortraitCorner
    let landscapeAutoScroll: Bool
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
    // ---- color background && visual effect background
    let contentBackgroundColor: Bool
    let contentBackgroundVisualEffect: Bool
    let contentBackGroundVisualEffectMaterial: Int //NSVisualEffectView.Material
    
    // two frames settings for a slot
    var cropperFrame: NSRect
    var contentFrame: NSRect
    
    init(
        tRTextRecognitionLevel: Int,
        tRMinimumTextHeight: Double,
        maximumFrameRate: Double,
        useEntryMode: UseEntryMode,
        isShowPhrases: Bool,
        cropperStyle: CropperStyle,
        isDropTitleWord: Bool,
        isAddLineBreak: Bool,
        isAddSpace: Bool,
        isDropFirstTitleWordInTranslation: Bool,
        isJoinTranslationLines: Bool,
        chineseCharacterConvertMode: ChineseCharacterConvertMode,
        isContentRetention: Bool,
        isShowWindowShadow: Bool,
        isWithAnimation: Bool,
        contentStyle: ContentStyle,
        portraitCorner: PortraitCorner,
        landscapeAutoScroll: Bool,
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
        contentBackgroundColor: Bool,
        contentBackgroundVisualEffect: Bool,
        contentBackGroundVisualEffectMaterial: Int, //NSVisualEffectView.Material
        cropperFrame: NSRect,
        contentFrame: NSRect
    ) {
        self.tRTextRecognitionLevel = tRTextRecognitionLevel
        self.tRMinimumTextHeight = tRMinimumTextHeight
        self.maximumFrameRate = maximumFrameRate
        self.useEntryMode = useEntryMode
        self.isShowPhrases = isShowPhrases
        self.cropperStyle = cropperStyle
        self.isDropTitleWord = isDropTitleWord
        self.isAddLineBreak = isAddLineBreak
        self.isAddSpace = isAddSpace
        self.isDropFirstTitleWordInTranslation = isDropFirstTitleWordInTranslation
        self.isJoinTranslationLines = isJoinTranslationLines
        self.chineseCharacterConvertMode = chineseCharacterConvertMode
        self.isContentRetention = isContentRetention
        self.isShowWindowShadow = isShowWindowShadow
        self.isWithAnimation = isWithAnimation
        self.contentStyle = contentStyle
        self.portraitCorner = portraitCorner
        self.landscapeAutoScroll = landscapeAutoScroll
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
        self.contentBackgroundColor = contentBackgroundColor
        self.contentBackgroundVisualEffect = contentBackgroundVisualEffect
        self.contentBackGroundVisualEffectMaterial = contentBackGroundVisualEffectMaterial //NSVisualEffectView.Material
        self.cropperFrame = cropperFrame
        self.contentFrame = contentFrame
    }
}

func settingsToData(_ settings: Settings) -> Data? {
    let data = try? PropertyListEncoder.init().encode(settings)
    return data
}

func dataToSettings(_ data: Data) -> Settings? {
    let settings = try? PropertyListDecoder.init().decode(Settings.self, from: data)
    return settings
}

fileprivate let defaultSettings = Settings(
    tRTextRecognitionLevel: VNRequestTextRecognitionLevel.fast.rawValue,
    tRMinimumTextHeight: systemDefaultMinimumTextHeight,
    maximumFrameRate: 4,
    useEntryMode: UseEntryMode.asFirstPriority,
    isShowPhrases: true,
    cropperStyle: CropperStyle.leadingBorder,
    isDropTitleWord: false,
    isAddLineBreak: true,
    isAddSpace: false,
    isDropFirstTitleWordInTranslation: true,
    isJoinTranslationLines: true,
    chineseCharacterConvertMode: ChineseCharacterConvertMode.notConvert,
    isContentRetention: false,
    isShowWindowShadow: true,
    isWithAnimation: true,
    contentStyle: ContentStyle.portrait,
    portraitCorner: PortraitCorner.topTrailing,
    landscapeAutoScroll: true,
    portraitMaxHeight: 100.0,
    landscapeMaxWidth: 160.0,
    fontSize: 18.0,
    fontRate: 0.75,
    theColorScheme: TheColorScheme.system,
    wordColor: colorToData(NSColor.labelColor)!,
    transColor: colorToData(NSColor.secondaryLabelColor)!,
    backgroundColor: colorToData(NSColor.windowBackgroundColor)!,
    textShadowToggle: false,
    shadowColor: colorToData(NSColor.labelColor)!,
    shadowRadius: 3,
    shadowXOffSet: 0.0,
    shadowYOffSet: 0.0,
    contentBackgroundColor: true,
    contentBackgroundVisualEffect: false,
    contentBackGroundVisualEffectMaterial: NSVisualEffectView.Material.titlebar.rawValue,
    cropperFrame: NSRect(x: 310, y: 500, width: 600, height: 200),
    contentFrame: NSRect(x: 100, y: 100, width: 200, height: 600)
)

struct SlotsSettingsView: View {
    @State private var isShowingPopover = false
    
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: "") {
                HStack {
                    Spacer()
                    
                    SlotsView()
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
                            alignment: .bottomTrailing)
                    
                    Spacer()
                }
            }
        }
    }
}

fileprivate struct InfoView: View {
    var body: some View {
        Text("Slot is a stored collection of all preferences settings (except global shortcut key, font name, is show toast option), and cropper window frame, and content window frame. This makes you switch them quickly. \n\nBut, if you switch them when playing, the crop rectangle of screen recording won't switch. You should stop playing before switch them.  \n\nYou can add as many slots as you like. You click the update button to dump current preferences settings and store it into the selected slot. You click the icon to switch and dump the selected slot settings into the current preferences settings. You can swipe left to delete a slot. You can attach a slot with a text label, by typing text after the icon. You can even clone the selected slot.")
            .padding()
            .frame(width: 400, height: 310)
    }
}

fileprivate struct ButtonsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    let selectedSlot: Slot?
    
    var body: some View {
        HStack {
            Button("Add") {
                let slot = Slot(context: managedObjectContext)
                slot.color = colorToData(NSColor.random())
                slot.label = ""
                slot.settings = settingsToData(defaultSettings)
                slot.createdDate = Date()
                slot.isSelected = false
                saveContext()
            }
            
            Button("Clone") {
                if let selectedSlot = selectedSlot {
                    let slot = Slot(context: managedObjectContext)
                    slot.color = colorToData(NSColor.random())
                    slot.label = "\(selectedSlot.label ?? "") cloned"
                    slot.settings = selectedSlot.settings
                    slot.createdDate = Date()
                    slot.isSelected = true
                    selectedSlot.isSelected = false
                    saveContext()
                }
            }
            .disabled(selectedSlot == nil)
            
            Button("Delete All") {
                showingAlert = true
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Delete All"),
                    message: Text("Are you sure? This action can't be undo."),
                    primaryButton: .default(
                        Text("Cancel"),
                        action: { print("Cancelled") }
                    ),
                    secondaryButton: .destructive(
                        Text("Delete"),
                        action: batchDeleteAllSlots
                    )
                )
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
    }
    
    @State private var showingAlert = false
}

fileprivate struct SlotsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Slot.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Slot.createdDate, ascending: true)
        ]
    ) var slots: FetchedResults<Slot>
    
    var selectedSlot: Slot? {
        slots.first { $0.isSelected }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            GroupBox {
                List {
                    ForEach(slots, id: \.createdDate) { slot in
                        let settings = dataToSettings(slot.settings!)!
                        HStack {
                            HStack {
                                Button(action: {
                                    for slot in slots {
                                        slot.isSelected = false
                                    }
                                    slot.isSelected = true
                                    saveContext()
                                    dumpSettings(from: settings)
                                }) {
                                    Image(systemName: slot.isSelected ? "cube.fill" : "cube")
                                        .font(.title)
                                        .foregroundColor(Color(dataToColor(slot.color!)!))
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                TextField("", text: Binding.init(
                                    get: { slot.label! },
                                    set: { newValue in
                                        slot.label = newValue
                                        saveContext()
                                    }
                                ))
                                .font(.callout)
                                .textFieldStyle(PlainTextFieldStyle())
                                .frame(maxWidth: 300)
                            }
                            
                            if slot.isSelected && !isSelectedSlotEqualWithCurrentSettings(settings) {
                                Button("Update", action: {
                                    let currentSettings = getCurrentSettingsX()
                                    slot.settings = settingsToData(currentSettings)!
                                    saveContext()
                                })
                            }
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            let slot = slots[index]
                            managedObjectContext.delete(slot)
                        }
                        saveContext()
                    }
                }
                .listStyle(PlainListStyle())
                .frame(width: 300, height: 40 + CGFloat(slots.count) * 35 < 800 ? 40 + CGFloat(slots.count) * 35 : 800)
            }
            
            ButtonsView(selectedSlot: selectedSlot)
        }
        .padding()
    }
    
    func getCurrentSettingsX() -> Settings {
        return Settings(
            tRTextRecognitionLevel: tRTextRecognitionLevel,
            tRMinimumTextHeight: tRMinimumTextHeight,
            maximumFrameRate: maximumFrameRate,
            useEntryMode: useEntryMode,
            isShowPhrases: isShowPhrases,
            cropperStyle: cropperStyle,
            isDropTitleWord: isDropTitleWord,
            isAddLineBreak: isAddLineBreak,
            isAddSpace: isAddSpace,
            isDropFirstTitleWordInTranslation: isDropFirstTitleWordInTranslation,
            isJoinTranslationLines: isJoinTranslationLines,
            chineseCharacterConvertMode: chineseCharacterConvertMode,
            isContentRetention: isContentRetention,
            isShowWindowShadow: isShowWindowShadow,
            isWithAnimation: isWithAnimation,
            contentStyle: contentStyle,
            portraitCorner: portraitCorner,
            landscapeAutoScroll: landscapeAutoScroll,
            portraitMaxHeight: portraitMaxHeight,
            landscapeMaxWidth: landscapeMaxWidth,
            fontSize: fontSize,
            fontRate: fontRate,
            theColorScheme: theColorScheme,
            wordColor: wordColor,
            transColor: transColor,
            backgroundColor: backgroundColor,
            textShadowToggle: textShadowToggle,
            shadowColor: shadowColor,
            shadowRadius: shadowRadius,
            shadowXOffSet: shadowXOffSet,
            shadowYOffSet: shadowYOffSet,
            contentBackgroundColor: contentBackgroundColor,
            contentBackgroundVisualEffect: contentBackgroundVisualEffect,
            contentBackGroundVisualEffectMaterial: contentBackGroundVisualEffectMaterial,
            cropperFrame: cropperWindow.frame,
            contentFrame: contentWindow.frame
        )
    }
    
    func isSelectedSlotEqualWithCurrentSettings(_ s: Settings) -> Bool {
        let result = s.tRTextRecognitionLevel == tRTextRecognitionLevel &&
            s.tRMinimumTextHeight == tRMinimumTextHeight &&
            s.maximumFrameRate == maximumFrameRate &&
            s.useEntryMode == useEntryMode &&
            s.isShowPhrases == isShowPhrases &&
            s.cropperStyle == cropperStyle &&
            s.isDropTitleWord == isDropTitleWord &&
            s.isAddLineBreak == isAddLineBreak &&
            s.isAddSpace == isAddSpace &&
            s.isDropFirstTitleWordInTranslation == isDropFirstTitleWordInTranslation &&
            s.isJoinTranslationLines == isJoinTranslationLines &&
            s.chineseCharacterConvertMode == chineseCharacterConvertMode &&
            s.isContentRetention == isContentRetention &&
            s.isShowWindowShadow == isShowWindowShadow &&
            s.isWithAnimation == isWithAnimation &&
            s.contentStyle == contentStyle &&
            s.portraitCorner == portraitCorner &&
            s.landscapeAutoScroll == landscapeAutoScroll &&
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
            s.contentBackgroundColor == contentBackgroundColor &&
            s.contentBackgroundVisualEffect == contentBackgroundVisualEffect &&
            s.contentBackGroundVisualEffectMaterial == contentBackGroundVisualEffectMaterial //NSVisualEffectView.Material
        
        return result
    }
    
    fileprivate func dumpSettings(from s: Settings) {
        tRTextRecognitionLevel = s.tRTextRecognitionLevel
        tRMinimumTextHeight = s.tRMinimumTextHeight
        maximumFrameRate = s.maximumFrameRate
        useEntryMode = s.useEntryMode
        isShowPhrases = s.isShowPhrases
        cropperStyle = s.cropperStyle
        isDropTitleWord = s.isDropTitleWord
        isAddLineBreak = s.isAddLineBreak
        isAddSpace = s.isAddSpace
        isDropFirstTitleWordInTranslation = s.isDropFirstTitleWordInTranslation
        isJoinTranslationLines = s.isJoinTranslationLines
        chineseCharacterConvertMode = s.chineseCharacterConvertMode
        isContentRetention = s.isContentRetention
        isShowWindowShadow = s.isShowWindowShadow
        isWithAnimation = s.isWithAnimation
        contentStyle = s.contentStyle
        portraitCorner = s.portraitCorner
        landscapeAutoScroll = s.landscapeAutoScroll
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
        contentBackgroundColor = s.contentBackgroundColor
        contentBackgroundVisualEffect = s.contentBackgroundVisualEffect
        contentBackGroundVisualEffectMaterial = s.contentBackGroundVisualEffectMaterial //NSVisualEffectView.Material
        cropperWindow.setFrame(s.cropperFrame, display: true)
        contentWindow.setFrame(s.contentFrame, display: true)
    }
    
    // isShowStoreButton need these almost all @AppStorage data
    @AppStorage(TRTextRecognitionLevelKey) var tRTextRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    @AppStorage(TRMinimumTextHeightKey) var tRMinimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315
    @AppStorage(MaximumFrameRateKey) private var maximumFrameRate: Double = 4

    @AppStorage(UseEntryModeKey) var useEntryMode: UseEntryMode = .asFirstPriority
    
    @AppStorage(IsShowPhrasesKey) var isShowPhrases: Bool = true
    
    @AppStorage(CropperStyleKey) var cropperStyle: CropperStyle = .closed
    
    @AppStorage(IsDropTitleWordKey) private var isDropTitleWord: Bool = false
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    @AppStorage(IsAddSpaceKey) private var isAddSpace: Bool = false
    @AppStorage(IsDropFirstTitleWordInTranslationKey) private var isDropFirstTitleWordInTranslation: Bool = true
    @AppStorage(IsJoinTranslationLinesKey) private var isJoinTranslationLines: Bool = true
    @AppStorage(ChineseCharacterConvertModeKey) private var chineseCharacterConvertMode: ChineseCharacterConvertMode = .notConvert

    @AppStorage(IsContentRetentionKey) private var isContentRetention = false
    
    @AppStorage(IsShowWindowShadowKey) private var isShowWindowShadow = false

    @AppStorage(IsWithAnimationKey) var isWithAnimation: Bool = true
    
    @AppStorage(ContentStyleKey) var contentStyle: ContentStyle = .portrait
    @AppStorage(PortraitCornerKey) var portraitCorner: PortraitCorner = .topTrailing
    @AppStorage(LandscapeAutoScrollKey) var landscapeAutoScroll: Bool = true
    @AppStorage(PortraitMaxHeightKey) var portraitMaxHeight: Double = 100.0
    @AppStorage(LandscapeMaxWidthKey) var landscapeMaxWidth: Double = 160.0
    
    @AppStorage(FontSizeKey) private var fontSize: Double = 18.0
    @AppStorage(FontRateKey) var fontRate: Double = 0.75
    
    @AppStorage(TheColorSchemeKey) var theColorScheme: TheColorScheme = .system
    
    @AppStorage(WordColorKey) var wordColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(TransColorKey) var transColor: Data = colorToData(NSColor.secondaryLabelColor)!
    @AppStorage(BackgroundColorKey) var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    
    @AppStorage(TextShadowToggleKey) var textShadowToggle: Bool = false
    @AppStorage(ShadowColorKey) var shadowColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(ShadowRadiusKey) var shadowRadius: Double = 3
    @AppStorage(ShadowXOffSetKey) var shadowXOffSet: Double = 0
    @AppStorage(ShadowYOffSetKey) var shadowYOffSet: Double = 0
    
    @AppStorage(ContentBackgroundColorKey) var contentBackgroundColor: Bool = true
    @AppStorage(ContentBackgroundVisualEffectKey) var contentBackgroundVisualEffect: Bool = false
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension NSColor {
    static func random() -> NSColor {
        return NSColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}

struct SlotsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SlotsSettingsView()
                .environmentObject(StatusData(isPlaying: false))

            InfoView()
        }
        .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
