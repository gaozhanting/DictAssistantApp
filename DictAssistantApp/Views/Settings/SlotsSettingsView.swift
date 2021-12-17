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
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: "") {
                HStack {
                    Spacer()
                    
                    SlotsView()
                        .overlay(
                            QuestionMarkView {
                                InfoView()
                            },
                            alignment: .bottomTrailing)
                    
                    Spacer()
                }
            }
        }
    }
}

struct Settings: Codable {
    // Recording
    var cropperStyle: Int
    var isCloseCropperWhenNotPlaying: Bool
    var maximumFrameRate: Double
    
    // Vision
    var tRTextRecognitionLevel: Int
    var tRMinimumTextHeight: Double
    
    // NLP
    var lemmaSearchLevel: Int
    var doPhraseRecognition: Bool
    
    // Dictionary
    var useAppleDictMode: Int
    var useEntryMode: Int
    
    // Content
    var isDropTitleWord: Bool
    var isAddLineBreak: Bool
    var isAddSpace: Bool
    var isDropFirstTitleWordInTranslation: Bool
    var isJoinTranslationLines: Bool
    var chineseCharacterConvertMode: Int
    
    // Appearance
    var contentStyle: Int
    var portraitCorner: Int
    var landscapeStyle: Int
    var portraitMaxHeight: Double
    var landscapeMaxWidth: Double
    
    var fontSize: Double
    var lineSpacing: Double
    var fontRate: Double
    
    var isShowWindowShadow: Bool
    var isWithAnimation: Bool
    var isContentRetention: Bool
    
    // two frames settings for a slot
    var cropperFrame: NSRect
    var contentFrame: NSRect
    
    init(
        cropperStyle: Int,
        isCloseCropperWhenNotPlaying: Bool,
        maximumFrameRate: Double,
        tRTextRecognitionLevel: Int,
        tRMinimumTextHeight: Double,
        lemmaSearchLevel: Int,
        doPhraseRecognition: Bool,
        useAppleDictMode: Int,
        useEntryMode: Int,
        isDropTitleWord: Bool,
        isAddLineBreak: Bool,
        isAddSpace: Bool,
        isDropFirstTitleWordInTranslation: Bool,
        isJoinTranslationLines: Bool,
        chineseCharacterConvertMode: Int,
        contentStyle: Int,
        portraitCorner: Int,
        portraitMaxHeight: Double,
        landscapeStyle: Int,
        landscapeMaxWidth: Double,
        fontSize: Double,
        lineSpacing: Double,
        fontRate: Double,
        isShowWindowShadow: Bool,
        isWithAnimation: Bool,
        isContentRetention: Bool,
        cropperFrame: NSRect,
        contentFrame: NSRect
    ) {
        self.cropperStyle = cropperStyle
        self.isCloseCropperWhenNotPlaying = isCloseCropperWhenNotPlaying
        self.maximumFrameRate = maximumFrameRate
        self.tRTextRecognitionLevel = tRTextRecognitionLevel
        self.tRMinimumTextHeight = tRMinimumTextHeight
        self.lemmaSearchLevel = lemmaSearchLevel
        self.doPhraseRecognition = doPhraseRecognition
        self.useAppleDictMode = useAppleDictMode
        self.useEntryMode = useEntryMode
        self.isDropTitleWord = isDropTitleWord
        self.isAddLineBreak = isAddLineBreak
        self.isAddSpace = isAddSpace
        self.isDropFirstTitleWordInTranslation = isDropFirstTitleWordInTranslation
        self.isJoinTranslationLines = isJoinTranslationLines
        self.chineseCharacterConvertMode = chineseCharacterConvertMode
        self.contentStyle = contentStyle
        self.portraitCorner = portraitCorner
        self.portraitMaxHeight = portraitMaxHeight
        self.landscapeStyle = landscapeStyle
        self.landscapeMaxWidth = landscapeMaxWidth
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
        self.fontRate = fontRate
        self.isShowWindowShadow = isShowWindowShadow
        self.isWithAnimation = isWithAnimation
        self.isContentRetention = isContentRetention
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

private let defaultSettings = Settings(
    cropperStyle: CropperStyle.leadingBorder.rawValue,
    isCloseCropperWhenNotPlaying: true,
    maximumFrameRate: 4,
    
    tRTextRecognitionLevel: VNRequestTextRecognitionLevel.fast.rawValue,
    tRMinimumTextHeight: systemDefaultMinimumTextHeight,
    
    lemmaSearchLevel: LemmaSearchLevel.database.rawValue,
    doPhraseRecognition: false,
    useAppleDictMode: UseAppleDictMode.afterBuiltIn.rawValue,
    useEntryMode: UseEntryMode.asFirstPriority.rawValue,
    
    isDropTitleWord: false,
    isAddLineBreak: true,
    isAddSpace: false,
    isDropFirstTitleWordInTranslation: true,
    isJoinTranslationLines: true,
    chineseCharacterConvertMode: ChineseCharacterConvertMode.notConvert.rawValue,
    
    contentStyle: ContentStyle.portrait.rawValue,
    portraitCorner: PortraitCorner.topTrailing.rawValue,
    portraitMaxHeight: 100.0,
    landscapeStyle: LandscapeStyle.normal.rawValue,
    landscapeMaxWidth: 160.0,
    
    fontSize: 14.0,
    lineSpacing: 0.0,
    fontRate: 0.9,
    
    isShowWindowShadow: true,
    isWithAnimation: true,
    isContentRetention: false,
    
    cropperFrame: defaultCropperFrame,
    contentFrame: defaultContentFrame
)

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
    
    func select(_ slot: Slot) {
        let settings = dataToSettings(slot.settings!)!
        
        for slot in slots {
            slot.isSelected = false
        }
        slot.isSelected = true
        saveContext()
        
        dumpSettings(from: settings)
        
        if statusData.isPlaying {
            restartPlaying()
        } else {
            switch stepPlayPhase {
            case .defaultPhase:
                logger.info("do nothing special side-effect.")
            case .windowsSettingPhase:
                logger.info("do make windows same style as normal windowsSettingPhase, for setting.")
                makeWindowsForSetting()
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            GroupBox {
                List {
                    ForEach(slots, id: \.createdDate) { slot in
                        HStack {
                            HStack {
                                Button(action: {
                                    select(slot)
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
    
    private func dumpSettings(from s: Settings) {
        cropperStyle = s.cropperStyle
        isCloseCropperWhenNotPlaying = s.isCloseCropperWhenNotPlaying
        maximumFrameRate = s.maximumFrameRate
        tRTextRecognitionLevel = s.tRTextRecognitionLevel
        tRMinimumTextHeight = s.tRMinimumTextHeight
        lemmaSearchLevel = s.lemmaSearchLevel
        doPhraseRecognition = s.doPhraseRecognition
        useAppleDictMode = s.useAppleDictMode
        useEntryMode = s.useEntryMode
        isDropTitleWord = s.isDropTitleWord
        isAddLineBreak = s.isAddLineBreak
        isAddSpace = s.isAddSpace
        isDropFirstTitleWordInTranslation = s.isDropFirstTitleWordInTranslation
        isJoinTranslationLines = s.isJoinTranslationLines
        chineseCharacterConvertMode = s.chineseCharacterConvertMode
        contentStyle = s.contentStyle
        portraitCorner = s.portraitCorner
        portraitMaxHeight = s.portraitMaxHeight
        landscapeStyle = s.landscapeStyle
        landscapeMaxWidth = s.landscapeMaxWidth
        fontSize = s.fontSize
        lineSpacing = s.lineSpacing
        fontRate = s.fontRate
        isShowWindowShadow = s.isShowWindowShadow
        isWithAnimation = s.isWithAnimation
        isContentRetention = s.isContentRetention
        cropperWindow.setFrame(s.cropperFrame, display: true)
        contentWindow.setFrame(s.contentFrame, display: true)
    }
    
    @AppStorage(CropperStyleKey) private var cropperStyle: Int = CropperStyle.empty.rawValue
    @AppStorage(IsCloseCropperWhenNotPlayingKey) private var isCloseCropperWhenNotPlaying: Bool = true
    @AppStorage(MaximumFrameRateKey) private var maximumFrameRate: Double = 4
    @AppStorage(TRTextRecognitionLevelKey) var tRTextRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    @AppStorage(TRMinimumTextHeightKey) var tRMinimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315
    @AppStorage(LemmaSearchLevelKey) private var lemmaSearchLevel: Int = LemmaSearchLevel.database.rawValue
    @AppStorage(DoPhraseRecognitionKey) var doPhraseRecognition: Bool = false
    @AppStorage(UseAppleDictModeKey) var useAppleDictMode: Int = UseAppleDictMode.afterBuiltIn.rawValue
    @AppStorage(UseEntryModeKey) private var useEntryMode: Int = UseEntryMode.asFirstPriority.rawValue
    @AppStorage(IsDropTitleWordKey) private var isDropTitleWord: Bool = false
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    @AppStorage(IsAddSpaceKey) private var isAddSpace: Bool = false
    @AppStorage(IsDropFirstTitleWordInTranslationKey) private var isDropFirstTitleWordInTranslation: Bool = true
    @AppStorage(IsJoinTranslationLinesKey) private var isJoinTranslationLines: Bool = true
    @AppStorage(ChineseCharacterConvertModeKey) private var chineseCharacterConvertMode: Int = ChineseCharacterConvertMode.notConvert.rawValue
    @AppStorage(ContentStyleKey) private var contentStyle: Int = ContentStyle.portrait.rawValue
    @AppStorage(PortraitCornerKey) private var portraitCorner: Int = PortraitCorner.topTrailing.rawValue
    @AppStorage(PortraitMaxHeightKey) var portraitMaxHeight: Double = 100.0
    @AppStorage(LandscapeStyleKey) var landscapeStyle: Int = LandscapeStyle.normal.rawValue
    @AppStorage(LandscapeMaxWidthKey) var landscapeMaxWidth: Double = 160.0
    @AppStorage(FontSizeKey) private var fontSize: Double = 14.0
    @AppStorage(LineSpacingKey) private var lineSpacing: Double = 0
    @AppStorage(FontRateKey) var fontRate: Double = 0.9
    @AppStorage(IsShowWindowShadowKey) private var isShowWindowShadow = false
    @AppStorage(IsWithAnimationKey) var isWithAnimation: Bool = true
    @AppStorage(IsContentRetentionKey) private var isContentRetention = false
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

private struct ButtonsView: View {
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

private struct InfoView: View {
    var body: some View {
        Text("Slot is a stored collection of the cropper window frame, the content window frame, and all preferences settings (exclude: global shortcut key, is show toast option, font name). This makes you switch them quickly. \n\nYou can add a default slot or clone a selected slot, as many as you like. You click the icon to switch and dump the selected slot settings into the current preferences settings. You swipe left to prompt to delete a slot. You can attach a slot with a text label, by typing text after the icon. When a slot is selected, changes of settings will be automatically saved in it. \n\nNote, if you update the App in the future, the new version App will delete all the slots before running. That is because the slot data may becomes incompatible when preference settings changed, sorry for the trouble.")
            .font(.callout)
            .padding()
            .frame(width: 400)
    }
}

struct SlotsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SlotsSettingsView()
                .environmentObject(StatusData(isPlaying: false))

            InfoView()
        }
//        .environment(\.locale, .init(identifier: "zh-Hant"))
        .environment(\.locale, .init(identifier: "en"))
    }
}
