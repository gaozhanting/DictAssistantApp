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
        SlotsView()
            .frame(width: panelWidth)
            .overlay(
                QuestionMarkView {
                    InfoView()
                }, alignment: .bottomTrailing)
    }
}

struct Settings: Codable {
    var portraitCorner: Int
    var portraitMaxHeight: Double
    var landscapeStyle: Int
    var landscapeMaxWidth: Double
    
    var contentPaddingStyle: Int
    var minimalistVPadding: Double
    var minimalistHPadding: Double
    
    var wordColor: Data
    var transColor: Data
    var backgroundColor: Data
    var contentHasShadow: Bool
    var useContentBackgroundVisualEffect: Bool
    var contentBackGroundVisualEffectMaterial: Int
    var theColorScheme: Int
    
    var fontSize: Int
    var lineSpacing: Double
    
    var cropperStyle: Int
    
    var maximumFrameRate: Int
    var recognitionLevel: Int
    var minimumTextHeight: Double
    var usesLanguageCorrection: Bool
    
    var isOpenLemma: Bool
    var isShowToast: Bool
    
    var isAddLineBreak: Bool
    var isShowContentFrame: Bool
    
    var highlightMode: Int
    var cropperHasShadow: Bool
    var hlBorderedStyle: Int
    var hlBorderedColor: Data
    var hlRectangleColor: Data
    var isShowIndex: Bool
    var strokeDownwardOffset: Double
    var strokeLineWidth: Double
    var strokeDashPainted: Double
    var strokeDashUnPainted: Double
    var indexPadding: Double
    var indexFontSize: Int
    
    // two frames settings for a slot
    var cropperFrame: NSRect
    var contentFrame: NSRect
    
    init(
        portraitCorner: Int,
        portraitMaxHeight: Double,
        landscapeStyle: Int,
        landscapeMaxWidth: Double,
        
        contentPaddingStyle: Int,
        minimalistVPadding: Double,
        minimalistHPadding: Double,
        
        wordColor: Data,
        transColor: Data,
        backgroundColor: Data,
        contentHasShadow: Bool,
        useContentBackgroundVisualEffect: Bool,
        contentBackGroundVisualEffectMaterial: Int,
        theColorScheme: Int,
        
        fontSize: Int,
        lineSpacing: Double,
        
        cropperStyle: Int,
        
        maximumFrameRate: Int,
        recognitionLevel: Int,
        minimumTextHeight: Double,
        usesLanguageCorrection: Bool,
        
        isOpenLemma: Bool,
        isShowToast: Bool,
        
        isAddLineBreak: Bool,
        isShowContentFrame: Bool,
        
        highlightMode: Int,
        cropperHasShadow: Bool,
        hlBorderedStyle: Int,
        hlBorderedColor: Data,
        hlRectangleColor: Data,
        isShowIndex: Bool,
        strokeDownwardOffset: Double,
        strokeLineWidth: Double,
        strokeDashPainted: Double,
        strokeDashUnPainted: Double,
        indexPadding: Double,
        indexFontSize: Int,
        
        cropperFrame: NSRect,
        contentFrame: NSRect
    ) {
        self.portraitCorner = portraitCorner
        self.portraitMaxHeight = portraitMaxHeight
        self.landscapeStyle = landscapeStyle
        self.landscapeMaxWidth = landscapeMaxWidth
        
        self.contentPaddingStyle = contentPaddingStyle
        self.minimalistVPadding = minimalistVPadding
        self.minimalistHPadding = minimalistHPadding
        
        self.wordColor = wordColor
        self.transColor = transColor
        self.backgroundColor = backgroundColor
        self.contentHasShadow = contentHasShadow
        self.useContentBackgroundVisualEffect = useContentBackgroundVisualEffect
        self.contentBackGroundVisualEffectMaterial = contentBackGroundVisualEffectMaterial
        self.theColorScheme = theColorScheme
        
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
        
        self.cropperStyle = cropperStyle
        
        self.maximumFrameRate = maximumFrameRate
        self.recognitionLevel = recognitionLevel
        self.minimumTextHeight = minimumTextHeight
        self.usesLanguageCorrection = usesLanguageCorrection
        
        self.isOpenLemma = isOpenLemma
        self.isShowToast = isShowToast
        
        self.isAddLineBreak = isAddLineBreak
        self.isShowContentFrame = isShowContentFrame
        
        self.highlightMode = highlightMode
        self.cropperHasShadow = cropperHasShadow
        self.hlBorderedStyle = hlBorderedStyle
        self.hlBorderedColor = hlBorderedColor
        self.hlRectangleColor = hlRectangleColor
        self.isShowIndex = isShowIndex
        self.strokeDownwardOffset = strokeDownwardOffset
        self.strokeLineWidth = strokeLineWidth
        self.strokeDashPainted = strokeDashPainted
        self.strokeDashUnPainted = strokeDashUnPainted
        self.indexPadding = indexPadding
        self.indexFontSize = indexFontSize
        
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
    portraitCorner: PortraitCornerDefault,
    portraitMaxHeight: PortraitMaxHeightDefault,
    landscapeStyle: LandscapeStyleDefault,
    landscapeMaxWidth: LandscapeMaxWidthDefault,
    
    contentPaddingStyle: ContentPaddingStyle.standard.rawValue,
    minimalistVPadding: 2.0,
    minimalistHPadding: 6.0,
    
    wordColor: WordColorDefault,
    transColor: TransColorDefault,
    backgroundColor: BackgroundColorDefault,
    contentHasShadow: ContentHasShadowDefault,
    useContentBackgroundVisualEffect: UseContentBackgroundVisualEffectDefault,
    contentBackGroundVisualEffectMaterial: ContentBackGroundVisualEffectMaterialDefault,
    theColorScheme: TheColorSchemeDefault,
    
    fontSize: 14,
    lineSpacing: 2.0,
    
    cropperStyle: CropperStyleDefault,
    
    maximumFrameRate: MaximumFrameRateDefault,
    recognitionLevel: RecognitionLevelDefault,
    minimumTextHeight: ZeroDefaultMinimumTextHeight,
    usesLanguageCorrection: false,
    
    isOpenLemma: false,
    isShowToast: true,
    
    isAddLineBreak: true,
    isShowContentFrame: true,
    
    highlightMode: HighlightModeDefault,
    cropperHasShadow: CropperHasShadowDefault,
    hlBorderedStyle: HLBorderedStyleDefault,
    hlBorderedColor: HLBorderedColorDefault,
    hlRectangleColor: HLRectangleColorDefault,
    isShowIndex: false,
    strokeDownwardOffset: StrokeDownwardOffsetDefault,
    strokeLineWidth: 1.6,
    strokeDashPainted: 1.0,
    strokeDashUnPainted: 3.0,
    indexPadding: 1.5,
    indexFontSize: 5,
    
    //
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
        VStack {
            GroupBox {
                SlotsListView(slots: slots, select: select)
            }
            
            ButtonsView(slots: slots)
        }
        .frame(width: 230)
        .padding()
    }
    
    private func dumpSettings(from s: Settings) {
        portraitCorner = s.portraitCorner
        portraitMaxHeight = s.portraitMaxHeight
        landscapeStyle = s.landscapeStyle
        landscapeMaxWidth = s.landscapeMaxWidth
        
        contentPaddingStyle = s.contentPaddingStyle
        minimalistVPadding = s.minimalistVPadding
        minimalistHPadding = s.minimalistHPadding
        
        wordColor = s.wordColor
        transColor = s.transColor
        backgroundColor = s.backgroundColor
        contentHasShadow = s.contentHasShadow
        useContentBackgroundVisualEffect = s.useContentBackgroundVisualEffect
        contentBackGroundVisualEffectMaterial = s.contentBackGroundVisualEffectMaterial
        theColorScheme = s.theColorScheme
        
        fontSize = s.fontSize
        lineSpacing = s.lineSpacing
        
        cropperStyle = s.cropperStyle
        
        maximumFrameRate = s.maximumFrameRate
        recognitionLevel = s.recognitionLevel
        minimumTextHeight = s.minimumTextHeight
        usesLanguageCorrection = s.usesLanguageCorrection
        
        isOpenLemma = s.isOpenLemma
        isShowToast = s.isShowToast
        
        isAddLineBreak = s.isAddLineBreak
        isShowContentFrame = s.isShowContentFrame
        
        highlightMode = s.highlightMode
        cropperHasShadow = s.cropperHasShadow
        hlBorderedStyle = s.hlBorderedStyle
        hlBorderedColor = s.hlBorderedColor
        hlRectangleColor = s.hlRectangleColor
        isShowIndex = s.isShowIndex
        strokeDownwardOffset = s.strokeDownwardOffset
        strokeLineWidth = s.strokeLineWidth
        strokeDashPainted = s.strokeDashPainted
        strokeDashUnPainted = s.strokeDashUnPainted
        indexPadding = s.indexPadding
        indexFontSize = s.indexFontSize
        
        cropperWindow.setFrame(s.cropperFrame, display: true)
        contentWindow.setFrame(s.contentFrame, display: true)
    }
    
    @AppStorage(PortraitCornerKey) var portraitCorner: Int = PortraitCornerDefault
    @AppStorage(PortraitMaxHeightKey) var portraitMaxHeight: Double = PortraitMaxHeightDefault
    @AppStorage(LandscapeStyleKey) var landscapeStyle: Int = LandscapeStyleDefault
    @AppStorage(LandscapeMaxWidthKey) var landscapeMaxWidth: Double = LandscapeMaxWidthDefault

    @AppStorage(ContentPaddingStyleKey) var contentPaddingStyle: Int = ContentPaddingStyle.standard.rawValue
    @AppStorage(MinimalistVPaddingKey) var minimalistVPadding: Double = 2.0
    @AppStorage(MinimalistHPaddingKey) var minimalistHPadding: Double = 6.0
    
    @AppStorage(WordColorKey) var wordColor: Data = WordColorDefault
    @AppStorage(TransColorKey) var transColor: Data = TransColorDefault
    @AppStorage(BackgroundColorKey) var backgroundColor: Data = BackgroundColorDefault
    @AppStorage(ContentHasShadowKey) var contentHasShadow: Bool = ContentHasShadowDefault
    @AppStorage(UseContentBackgroundVisualEffectKey) var useContentBackgroundVisualEffect: Bool = UseContentBackgroundVisualEffectDefault
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) var contentBackGroundVisualEffectMaterial: Int = ContentBackGroundVisualEffectMaterialDefault
    @AppStorage(TheColorSchemeKey) var theColorScheme: Int = TheColorSchemeDefault

    @AppStorage(FontSizeKey) var fontSize: Int = 14
    @AppStorage(LineSpacingKey) var lineSpacing: Double = 2.0

    @AppStorage(CropperStyleKey) var cropperStyle: Int = CropperStyleDefault

    @AppStorage(MaximumFrameRateKey) var maximumFrameRate: Int = MaximumFrameRateDefault
    @AppStorage(RecognitionLevelKey) var recognitionLevel: Int = RecognitionLevelDefault
    @AppStorage(MinimumTextHeightKey) var minimumTextHeight: Double = ZeroDefaultMinimumTextHeight
    @AppStorage(UsesLanguageCorrectionKey) var usesLanguageCorrection: Bool = false
    
    @AppStorage(IsOpenLemmaKey) var isOpenLemma: Bool = false
    @AppStorage(IsShowToastKey) var isShowToast: Bool = true

    @AppStorage(IsAddLineBreakKey) var isAddLineBreak: Bool = true
    @AppStorage(IsShowContentFrameKey) var isShowContentFrame: Bool = true

    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightModeDefault
    @AppStorage(CropperHasShadowKey) var cropperHasShadow: Bool = CropperHasShadowDefault
    @AppStorage(HLBorderedStyleKey) var hlBorderedStyle: Int = HLBorderedStyleDefault
    @AppStorage(HLBorderedColorKey) var hlBorderedColor: Data = HLBorderedColorDefault
    @AppStorage(HLRectangleColorKey) var hlRectangleColor: Data = HLRectangleColorDefault
    @AppStorage(IsShowIndexKey) var isShowIndex: Bool = false
    @AppStorage(StrokeDownwardOffsetKey) var strokeDownwardOffset: Double = StrokeDownwardOffsetDefault
    @AppStorage(StrokeLineWidthKey) var strokeLineWidth: Double = 1.6
    @AppStorage(StrokeDashPaintedKey) var strokeDashPainted: Double = 1.0
    @AppStorage(StrokeDashUnPaintedKey) var strokeDashUnPainted: Double = 3.0
    @AppStorage(IndexPaddingKey) var indexPadding: Double = 1.5
    @AppStorage(IndexFontSizeKey) var indexFontSize: Int = 5
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

private struct SlotsListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    let slots: FetchedResults<Slot>
    let select: (Slot) -> Void

    var body: some View {
        List {
            ForEach(slots, id: \.createdDate) { slot in
                SlotItemView(slot: slot, select: select)
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
        .frame(height: 40 + CGFloat(slots.count) * 35 < 800 ? 40 + CGFloat(slots.count) * 35 : 800)
    }
}

private struct SlotItemView: View {
    let slot: Slot
    let select: (Slot) -> Void
    
    var body: some View {
        HStack {
            HStack {
                Button(action: {
                    select(slot)
                }) {
                    Image(systemName: slot.isSelected ? "shippingbox.circle.fill" : "shippingbox.circle")
                        .font(.title)
                        .foregroundColor(Color(dataToColor(slot.color!)!))
                }
                .buttonStyle(PlainButtonStyle())
                
                TextField("", text: Binding.init(
                    get: { slot.label ?? "" },
                    set: { newValue in
                        slot.label = newValue
                        saveContext()
                    }
                ))
                .font(.callout)
                .textFieldStyle(PlainTextFieldStyle())
            }
            .shadow(color: slot.isSelected ? Color.primary : Color.clear, radius: slot.isSelected ? 1 : 0)
        }
    }
}

private struct ButtonsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    let slots: FetchedResults<Slot>
    
    var selectedSlot: Slot? {
        slots.first { $0.isSelected }
    }
    
    func add() {
        let slot = Slot(context: managedObjectContext)
        slot.color = colorToData(NSColor.random())
        slot.label = ""
        slot.settings = settingsToData(defaultSettings)
        slot.createdDate = Date()
        slot.isSelected = false
        saveContext()
    }
        
    func delete() {
        if let selectedSlot = selectedSlot {
            managedObjectContext.delete(selectedSlot)
            saveContext()
        }
    }
    
    func clone() {
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
    
    func up() {
        if let selectedSlot = selectedSlot {
            if let i = slots.firstIndex(of: selectedSlot) {
                if (i - 1) >= 0 {
                    let previousSlot = slots[i - 1]
                    (selectedSlot.createdDate, previousSlot.createdDate) = (previousSlot.createdDate, selectedSlot.createdDate)
                    saveContext()
                }
            }
        }
    }
    
    func down() {
        if let selectedSlot = selectedSlot {
            if let i = slots.firstIndex(of: selectedSlot) {
                if (i + 1) < slots.count {
                    let nextSlot = slots[i + 1]
                    (selectedSlot.createdDate, nextSlot.createdDate) = (nextSlot.createdDate, selectedSlot.createdDate)
                    saveContext()
                }
            }
        }
    }
    
    func clear() {
        showingAlert = true
    }
    
    var body: some View {
        GroupBox {
            HStack {
                Button(action: add) {
                    Image(systemName: "plus")
                }
                
                Group {
                    Button(action: delete) {
                        Image(systemName: "minus")
                    }
                    
                    Button(action: clone) {
                        Image(systemName: "plus.rectangle.on.rectangle")
                    }
                    .help("clone")
                    
                    Button(action: up) {
                        Image(systemName: "arrow.up")
                    }
                    
                    Button(action: down) {
                        Image(systemName: "arrow.down")
                    }
                }
                .disabled(selectedSlot == nil)
                
                Button(action: clear) {
                    Image(systemName: "trash")
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Delete all"),
                        message: Text("Are you sure? This action can't be undo."),
                        primaryButton: .default(
                            Text("Cancel")
                        ),
                        secondaryButton: .destructive(
                            Text("Delete"),
                            action: batchDeleteAllSlots
                        )
                    )
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    @State var showingAlert = false
}

private struct InfoView: View {
    var body: some View {
        Text("You create a slot and select it by click on the box icon, then all the settings in current Scene Tab are all stored in that slot, and the current content window frame and cropper window frame are stored as well. You can attach a slot with a text label, by typing text after the icon. When a slot is selected, changes of settings will be automatically saved in it. \n\nBecause you can use the App in many scenes, for example: reading webpages, reading books, reading subtitles when watching videos or playing with Google Chrome live caption (which is more suitable because both are auto streams), etc. Slots makes you switch them quickly. You could switch them more quickly by setting a global shortcut key of Show Slots Tab in Shortcuts Tab.  \n\nNote, if you update the App in the future, the new version App will delete all the slots before running. That is because the slot data may becomes incompatible when scene settings changed, sorry for the trouble.")
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
                .environment(\.managedObjectContext, persistentContainer.viewContext)

            InfoView()
        }
    }
}
