//
//  SlotsSettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/8/6.
//

import SwiftUI
import Preferences
import Vision

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

private struct InfoView: View {
    var body: some View {
        Text("Slot is a stored collection of all preferences settings (except global shortcut key, font name, is show toast option), and cropper window frame, and content window frame. This makes you switch them quickly. \n\nBut, if you switch them when playing, the crop rectangle of screen recording won't switch. You should stop playing before switch them.  \n\nYou can add as many slots as you like. You click the update button to dump current preferences settings and store it into the selected slot. You click the icon to switch and dump the selected slot settings into the current preferences settings. You can swipe left to delete a slot. You can attach a slot with a text label, by typing text after the icon. You can even clone the selected slot.")
            .padding()
            .frame(width: 400, height: 310)
    }
}

private struct SlotsView: View {
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
                        HStack {
                            HStack {
                                Button(action: { select(slot) }) {
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

    func select(_ slot: Slot) -> Void {
        for slot in slots {
            slot.isSelected = false
        }
        slot.isSelected = true
        saveContext()
        
        tRTextRecognitionLevel = Int(slot.tRTextRecognitionLevel)
        tRMinimumTextHeight = slot.tRMinimumTextHeight
        maximumFrameRate = slot.maximumFrameRate
        useEntryMode = UseEntryMode(rawValue: Int(slot.useEntryMode))!
        isShowPhrases = slot.isShowPhrases
        cropperStyle = CropperStyle(rawValue: Int(slot.cropperStyle))!
        isDropTitleWord = slot.isDropTitleWord
        isAddLineBreak = slot.isAddLineBreak
        isAddSpace = slot.isAddSpace
        isDropFirstTitleWordInTranslation = slot.isDropFirstTitleWordInTranslation
        isJoinTranslationLines = slot.isJoinTranslationLines
        chineseCharacterConvertMode = ChineseCharacterConvertMode(rawValue: Int(slot.chineseCharacterConvertMode))!
        isContentRetention = slot.isContentRetention
        isShowWindowShadow = slot.isShowWindowShadow
        isWithAnimation = slot.isWithAnimation
        contentStyle = ContentStyle(rawValue: Int(slot.contentStyle))!
        portraitCorner = PortraitCorner(rawValue: Int(slot.portraitCorner))!
        landscapeAutoScroll = slot.landscapeAutoScroll
        portraitMaxHeight = slot.portraitMaxHeight
        landscapeMaxWidth = slot.landscapeMaxWidth
        fontSize = slot.fontSize
        fontRate = slot.fontRate
        theColorScheme = TheColorScheme(rawValue: Int(slot.theColorScheme))!
        wordColor =  slot.wordColor!
        transColor = slot.transColor!
        backgroundColor = slot.backgroundColor!
        textShadowToggle = slot.textShadowToggle
        shadowColor = slot.shadowColor!
        shadowRadius = slot.shadowRadius
        shadowXOffset = slot.shadowXOffset
        shadowYOffset = slot.shadowYOffset
        useContentBackgroundColor = slot.useContentBackgroundColor
        useContentBackgroundVisualEffect = slot.useContentBackgroundVisualEffect
        contentBackGroundVisualEffectMaterial = Int(slot.contentBackGroundVisualEffectMaterial)
    }
    
    @AppStorage(TRTextRecognitionLevelKey) var tRTextRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    @AppStorage(TRMinimumTextHeightKey) var tRMinimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315
    @AppStorage(MaximumFrameRateKey) private var maximumFrameRate: Double = 4
    @AppStorage(UseEntryModeKey) private var useEntryMode: UseEntryMode = .asFirstPriority
    @AppStorage(IsShowPhrasesKey) private var isShowPhrases: Bool = true
    @AppStorage(CropperStyleKey) private var cropperStyle: CropperStyle = .closed
    @AppStorage(IsDropTitleWordKey) private var isDropTitleWord: Bool = false
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    @AppStorage(IsAddSpaceKey) private var isAddSpace: Bool = false
    @AppStorage(IsDropFirstTitleWordInTranslationKey) private var isDropFirstTitleWordInTranslation: Bool = true
    @AppStorage(IsJoinTranslationLinesKey) private var isJoinTranslationLines: Bool = true
    @AppStorage(ChineseCharacterConvertModeKey) private var chineseCharacterConvertMode: ChineseCharacterConvertMode = .notConvert
    @AppStorage(IsContentRetentionKey) private var isContentRetention = false
    @AppStorage(IsShowWindowShadowKey) private var isShowWindowShadow = false
    @AppStorage(IsWithAnimationKey) private var isWithAnimation: Bool = true
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portrait
    @AppStorage(PortraitCornerKey) private var portraitCorner: PortraitCorner = .topTrailing
    @AppStorage(LandscapeAutoScrollKey) private var landscapeAutoScroll: Bool = true
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 100.0
    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 160.0
    @AppStorage(FontSizeKey) private var fontSize: Double = 18.0
    @AppStorage(FontRateKey) private var fontRate: Double = 0.75
    @AppStorage(TheColorSchemeKey) private var theColorScheme: TheColorScheme = .system
    @AppStorage(WordColorKey) private var wordColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(TransColorKey) private var transColor: Data = colorToData(NSColor.secondaryLabelColor)!
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    @AppStorage(TextShadowToggleKey) private var textShadowToggle: Bool = false
    @AppStorage(ShadowColorKey) private var shadowColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(ShadowRadiusKey) private var shadowRadius: Double = 3
    @AppStorage(ShadowXOffSetKey) private var shadowXOffset: Double = 0
    @AppStorage(ShadowYOffSetKey) private var shadowYOffset: Double = 2
    @AppStorage(UseContentBackgroundColorKey) private var useContentBackgroundColor: Bool = true
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
}

private struct ButtonsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    let selectedSlot: Slot?
    
    var body: some View {
        HStack {
            Button("Add") {
                let slot = Slot(context: managedObjectContext)
                slot.color = colorToData(NSColor.random())
                slot.label = ""
                slot.createdDate = Date()
                slot.isSelected = false
                
                slot.tRTextRecognitionLevel = Int64(VNRequestTextRecognitionLevel.fast.rawValue)
                slot.tRMinimumTextHeight = systemDefaultMinimumTextHeight
                slot.maximumFrameRate = 4
                slot.useEntryMode = Int64(UseEntryMode.asFirstPriority.rawValue)
                slot.isShowPhrases = true
                slot.cropperStyle = Int64(CropperStyle.leadingBorder.rawValue)
                slot.isDropTitleWord = false
                slot.isAddLineBreak = true
                slot.isAddSpace = false
                slot.isDropFirstTitleWordInTranslation = true
                slot.isJoinTranslationLines = true
                slot.chineseCharacterConvertMode = Int64(ChineseCharacterConvertMode.notConvert.rawValue)
                slot.isContentRetention = false
                slot.isShowWindowShadow = true
                slot.isWithAnimation = true
                slot.contentStyle = Int64(ContentStyle.portrait.rawValue)
                slot.portraitCorner = Int64(PortraitCorner.topTrailing.rawValue)
                slot.landscapeAutoScroll = true
                slot.portraitMaxHeight = 100.0
                slot.landscapeMaxWidth = 160.0
                slot.fontSize = 18.0
                slot.fontRate = 0.75
                slot.theColorScheme = Int64(TheColorScheme.system.rawValue)
                slot.wordColor = colorToData(NSColor.labelColor)!
                slot.transColor = colorToData(NSColor.secondaryLabelColor)!
                slot.backgroundColor = colorToData(NSColor.windowBackgroundColor)!
                slot.textShadowToggle = false
                slot.shadowColor = colorToData(NSColor.labelColor)!
                slot.shadowRadius = 3
                slot.shadowXOffset = 0.0
                slot.shadowYOffset = 0.0
                slot.useContentBackgroundColor = true
                slot.useContentBackgroundVisualEffect = false
                slot.contentBackGroundVisualEffectMaterial = Int64(NSVisualEffectView.Material.titlebar.rawValue)
                
                saveContext()
            }
            
            Button("Clone") {
                if let selectedSlot = selectedSlot {
                    let slot = Slot(context: managedObjectContext)
                    slot.color = colorToData(NSColor.random())
                    slot.label = "\(selectedSlot.label ?? "") cloned"
                    slot.createdDate = Date()
                    slot.isSelected = true
                    
                    slot.tRTextRecognitionLevel = selectedSlot.tRTextRecognitionLevel
                    slot.tRMinimumTextHeight = selectedSlot.tRMinimumTextHeight
                    slot.maximumFrameRate = selectedSlot.maximumFrameRate
                    slot.useEntryMode = selectedSlot.useEntryMode
                    slot.isShowPhrases = selectedSlot.isShowPhrases
                    slot.cropperStyle = selectedSlot.cropperStyle
                    slot.isDropTitleWord = selectedSlot.isDropTitleWord
                    slot.isAddLineBreak = selectedSlot.isAddLineBreak
                    slot.isAddSpace = selectedSlot.isAddSpace
                    slot.isDropFirstTitleWordInTranslation = selectedSlot.isDropFirstTitleWordInTranslation
                    slot.isJoinTranslationLines = selectedSlot.isJoinTranslationLines
                    slot.chineseCharacterConvertMode = selectedSlot.chineseCharacterConvertMode
                    slot.isContentRetention = selectedSlot.isContentRetention
                    slot.isShowWindowShadow = selectedSlot.isShowWindowShadow
                    slot.isWithAnimation = selectedSlot.isWithAnimation
                    slot.contentStyle = selectedSlot.contentStyle
                    slot.portraitCorner = selectedSlot.portraitCorner
                    slot.landscapeAutoScroll = selectedSlot.landscapeAutoScroll
                    slot.portraitMaxHeight = selectedSlot.portraitMaxHeight
                    slot.landscapeMaxWidth = selectedSlot.landscapeMaxWidth
                    slot.fontSize = selectedSlot.fontSize
                    slot.fontRate = selectedSlot.fontRate
                    slot.theColorScheme = selectedSlot.theColorScheme
                    slot.wordColor =  selectedSlot.wordColor
                    slot.transColor = selectedSlot.transColor
                    slot.backgroundColor = selectedSlot.backgroundColor
                    slot.textShadowToggle = selectedSlot.textShadowToggle
                    slot.shadowColor = selectedSlot.shadowColor
                    slot.shadowRadius = selectedSlot.shadowRadius
                    slot.shadowXOffset = selectedSlot.shadowXOffset
                    slot.shadowYOffset = selectedSlot.shadowYOffset
                    slot.useContentBackgroundColor = selectedSlot.useContentBackgroundColor
                    slot.useContentBackgroundVisualEffect = selectedSlot.useContentBackgroundVisualEffect
                    slot.contentBackGroundVisualEffectMaterial = selectedSlot.contentBackGroundVisualEffectMaterial
                    
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
