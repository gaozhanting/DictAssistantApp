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
    // Recording
    var cropperStyle: Int
    var isCloseCropperWhenNotPlaying: Bool
    var maximumFrameRate: Double
    
    // Vision
    var tRTextRecognitionLevel: Int
    var tRMinimumTextHeight: Double
    
    // English
    var titleWord: Int
    var lemmaSearchLevel: Int
    var isShowPhrases: Bool
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
    var fontRate: Double
    
    var wordColor: Data
    var transColor: Data
    var backgroundColor: Data
    
    var textShadowToggle: Bool
    var shadowColor: Data
    var shadowRadius: Double
    var shadowXOffSet: Double
    var shadowYOffSet: Double
    
    var useContentBackgroundColor: Bool
    var useContentBackgroundVisualEffect: Bool
    var contentBackGroundVisualEffectMaterial: Int //NSVisualEffectView.Material
    
    var theColorScheme: Int
    
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
        titleWord: Int,
        lemmaSearchLevel: Int,
        isShowPhrases: Bool,
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
        fontRate: Double,
        wordColor: Data,
        transColor: Data,
        backgroundColor: Data,
        textShadowToggle: Bool,
        shadowColor: Data,
        shadowRadius: Double,
        shadowXOffSet: Double,
        shadowYOffSet: Double,
        useContentBackgroundColor: Bool,
        useContentBackgroundVisualEffect: Bool,
        contentBackGroundVisualEffectMaterial: Int, //NSVisualEffectView.Material
        theColorScheme: Int,
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
        self.titleWord = titleWord
        self.lemmaSearchLevel = lemmaSearchLevel
        self.isShowPhrases = isShowPhrases
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
        self.fontRate = fontRate
        self.wordColor = wordColor
        self.transColor = transColor
        self.backgroundColor = backgroundColor
        self.textShadowToggle = textShadowToggle
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowXOffSet = shadowXOffSet
        self.shadowYOffSet = shadowYOffSet
        self.useContentBackgroundColor = useContentBackgroundColor
        self.useContentBackgroundVisualEffect = useContentBackgroundVisualEffect
        self.contentBackGroundVisualEffectMaterial = contentBackGroundVisualEffectMaterial //NSVisualEffectView.Material
        self.theColorScheme = theColorScheme
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
    titleWord: TitleWord.lemma.rawValue,
    lemmaSearchLevel: LemmaSearchLevel.database.rawValue,
    isShowPhrases: true,
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
    fontRate: 0.9,
    wordColor: colorToData(NSColor.labelColor)!,
    transColor: colorToData(NSColor.secondaryLabelColor)!,
    backgroundColor: colorToData(NSColor.windowBackgroundColor)!,
    textShadowToggle: false,
    shadowColor: colorToData(NSColor.labelColor)!,
    shadowRadius: 3,
    shadowXOffSet: 0.0,
    shadowYOffSet: 0.0,
    useContentBackgroundColor: true,
    useContentBackgroundVisualEffect: false,
    contentBackGroundVisualEffectMaterial: NSVisualEffectView.Material.titlebar.rawValue,
    theColorScheme: TheColorScheme.system.rawValue,
    isShowWindowShadow: true,
    isWithAnimation: true,
    isContentRetention: false,
    cropperFrame: defaultCropperFrame,
    contentFrame: defaultContentFrame
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

private struct InfoView: View {
    var body: some View {
        Text("Slot is a stored collection of the cropper window frame, the content window frame, and all preferences settings (exclude: global shortcut key, is show toast option, font name). This makes you switch them quickly. \n\nBut, if you switch them when playing, the crop rectangle of screen recording won't switch. You should stop playing before switch them.  \n\nYou can add a default slot or clone a selected slot, as many as you like. You click the icon to switch and dump the selected slot settings into the current preferences settings. You swipe left to delete a slot. You can attach a slot with a text label, by typing text after the icon. When a slot is selected, changes of settings will be auto saved in it. \n\nNote, if you update the App in the future, the new version App will delete all the slots before running. That is because the slot data may becomes incompatible when preference settings changed, sorry for the trouble.")
            .font(.callout)
            .padding()
            .frame(width: 400, height: 340)
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
        titleWord = s.titleWord
        lemmaSearchLevel = s.lemmaSearchLevel
        isShowPhrases = s.isShowPhrases
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
        fontRate = s.fontRate
        wordColor = s.wordColor
        transColor = s.transColor
        backgroundColor = s.backgroundColor
        textShadowToggle = s.textShadowToggle
        shadowColor = s.shadowColor
        shadowRadius = s.shadowRadius
        shadowXOffSet = s.shadowXOffSet
        shadowYOffSet = s.shadowYOffSet
        useContentBackgroundColor = s.useContentBackgroundColor
        useContentBackgroundVisualEffect = s.useContentBackgroundVisualEffect
        contentBackGroundVisualEffectMaterial = s.contentBackGroundVisualEffectMaterial //NSVisualEffectView.Material
        theColorScheme = s.theColorScheme
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
    @AppStorage(TitleWordKey) private var titleWord: Int = TitleWord.lemma.rawValue
    @AppStorage(LemmaSearchLevelKey) private var lemmaSearchLevel: Int = LemmaSearchLevel.database.rawValue
    @AppStorage(IsShowPhrasesKey) var isShowPhrases: Bool = true
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
    @AppStorage(FontRateKey) var fontRate: Double = 0.9
    @AppStorage(WordColorKey) var wordColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(TransColorKey) var transColor: Data = colorToData(NSColor.secondaryLabelColor)!
    @AppStorage(BackgroundColorKey) var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    @AppStorage(TextShadowToggleKey) var textShadowToggle: Bool = false
    @AppStorage(ShadowColorKey) var shadowColor: Data = colorToData(NSColor.labelColor)!
    @AppStorage(ShadowRadiusKey) var shadowRadius: Double = 3
    @AppStorage(ShadowXOffSetKey) var shadowXOffSet: Double = 0
    @AppStorage(ShadowYOffSetKey) var shadowYOffSet: Double = 0
    @AppStorage(UseContentBackgroundColorKey) var useContentBackgroundColor: Bool = true
    @AppStorage(UseContentBackgroundVisualEffectKey) var useContentBackgroundVisualEffect: Bool = false
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    @AppStorage(TheColorSchemeKey) private var theColorScheme: Int = TheColorScheme.system.rawValue
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
