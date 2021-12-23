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
        
//        HStack {
//            SlotsView()
//            //                        .overlay(
//            //                            QuestionMarkView {
//            //                                InfoView()
//            //                            },
//            //                            alignment: .bottomTrailing)
//
//        }
    }
}

struct Settings: Codable {
    var contentLayout: Int
    var portraitCorner: Int
    var portraitMaxHeight: Double
    var landscapeStyle: Int
    var landscapeMaxWidth: Double
    
    var contentPaddingStyle: Int
    var standardCornerRadius: Double
    var minimalistVPadding: Double
    var minimalistHPadding: Double
    
    var fontSize: Int
    var lineSpacing: Double
    
    var cropperStyle: Int
    
    var maximumFrameRate: Double
    var tRTextRecognitionLevel: Int
    var tRMinimumTextHeight: Double
    
    var lemmaSearchLevel: Int
    
    var isAddLineBreak: Bool
    var isAddSpace: Bool
    
    var highlightMode: Int
    var hLRectangleColor: Data
    var strokeDownwardOffset: Double
    var strokeLineWidth: Double
    var strokeDashPainted: Double
    var strokeDashUnPainted: Double
    var indexPadding: Double
    var indexFontSize: Int
    var isAlwaysRefreshHighlight: Bool
    
    // two frames settings for a slot
    var cropperFrame: NSRect
    var contentFrame: NSRect
    
    init(
        contentLayout: Int,
        portraitCorner: Int,
        portraitMaxHeight: Double,
        landscapeStyle: Int,
        landscapeMaxWidth: Double,
        
        contentPaddingStyle: Int,
        standardCornerRadius: Double,
        minimalistVPadding: Double,
        minimalistHPadding: Double,
        
        fontSize: Int,
        lineSpacing: Double,
        
        cropperStyle: Int,
        
        maximumFrameRate: Double,
        tRTextRecognitionLevel: Int,
        tRMinimumTextHeight: Double,
        lemmaSearchLevel: Int,
        
        isAddLineBreak: Bool,
        isAddSpace: Bool,
        
        highlightMode: Int,
        hLRectangleColor: Data,
        strokeDownwardOffset: Double,
        strokeLineWidth: Double,
        strokeDashPainted: Double,
        strokeDashUnPainted: Double,
        indexPadding: Double,
        indexFontSize: Int,
        isAlwaysRefreshHighlight: Bool,
        
        cropperFrame: NSRect,
        contentFrame: NSRect
    ) {
        self.contentLayout = contentLayout
        self.portraitCorner = portraitCorner
        self.portraitMaxHeight = portraitMaxHeight
        self.landscapeStyle = landscapeStyle
        self.landscapeMaxWidth = landscapeMaxWidth
        
        self.contentPaddingStyle = contentPaddingStyle
        self.standardCornerRadius = standardCornerRadius
        self.minimalistVPadding = minimalistVPadding
        self.minimalistHPadding = minimalistHPadding
        
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
        
        self.cropperStyle = cropperStyle
        
        self.maximumFrameRate = maximumFrameRate
        self.tRTextRecognitionLevel = tRTextRecognitionLevel
        self.tRMinimumTextHeight = tRMinimumTextHeight
        
        self.lemmaSearchLevel = lemmaSearchLevel
        
        self.isAddLineBreak = isAddLineBreak
        self.isAddSpace = isAddSpace
        
        self.highlightMode = highlightMode
        self.hLRectangleColor = hLRectangleColor
        self.strokeDownwardOffset = strokeDownwardOffset
        self.strokeLineWidth = strokeLineWidth
        self.strokeDashPainted = strokeDashPainted
        self.strokeDashUnPainted = strokeDashUnPainted
        self.indexPadding = indexPadding
        self.indexFontSize = indexFontSize
        self.isAlwaysRefreshHighlight = isAlwaysRefreshHighlight
        
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
    contentLayout: ContentLayout.portrait.rawValue,
    portraitCorner: PortraitCorner.topTrailing.rawValue,
    portraitMaxHeight: 100.0,
    landscapeStyle: LandscapeStyle.normal.rawValue,
    landscapeMaxWidth: 160.0,
    
    contentPaddingStyle: ContentPaddingStyle.standard.rawValue,
    standardCornerRadius: 6.0,
    minimalistVPadding: 2.0,
    minimalistHPadding: 6.0,
    
    fontSize: 14,
    lineSpacing: 0.0,
    
    cropperStyle: CropperStyle.leadingBorder.rawValue,
    
    maximumFrameRate: 4.0,
    tRTextRecognitionLevel: VNRequestTextRecognitionLevel.fast.rawValue,
    tRMinimumTextHeight: systemDefaultMinimumTextHeight,
    lemmaSearchLevel: LemmaSearchLevel.database.rawValue,
    
    isAddLineBreak: true,
    isAddSpace: false,
    
    highlightMode: HighlightMode.dotted.rawValue,
    hLRectangleColor: colorToData(NSColor.red.withAlphaComponent(0.15))!,
    strokeDownwardOffset: 5.0,
    strokeLineWidth: 1.6,
    strokeDashPainted: 1.0,
    strokeDashUnPainted: 3.0,
    indexPadding: 2.0,
    indexFontSize: 7,
    isAlwaysRefreshHighlight: false,
    
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
        contentLayout = s.contentLayout
        portraitCorner = s.portraitCorner
        portraitMaxHeight = s.portraitMaxHeight
        landscapeStyle = s.landscapeStyle
        landscapeMaxWidth = s.landscapeMaxWidth
        
        contentPaddingStyle = s.contentPaddingStyle
        standardCornerRadius = s.standardCornerRadius
        minimalistVPadding = s.minimalistVPadding
        minimalistHPadding = s.minimalistHPadding
        
        fontSize = s.fontSize
        lineSpacing = s.lineSpacing
        
        cropperStyle = s.cropperStyle
        
        maximumFrameRate = s.maximumFrameRate
        tRTextRecognitionLevel = s.tRTextRecognitionLevel
        tRMinimumTextHeight = s.tRMinimumTextHeight
        
        lemmaSearchLevel = s.lemmaSearchLevel
        
        isAddLineBreak = s.isAddLineBreak
        isAddSpace = s.isAddSpace
        
        highlightMode = s.highlightMode
        hLRectangleColor = s.hLRectangleColor
        strokeDownwardOffset = s.strokeDownwardOffset
        strokeLineWidth = s.strokeLineWidth
        strokeDashPainted = s.strokeDashPainted
        strokeDashUnPainted = s.strokeDashUnPainted
        indexPadding = s.indexPadding
        indexFontSize = s.indexFontSize
        isAlwaysRefreshHighlight = s.isAlwaysRefreshHighlight
        
        cropperWindow.setFrame(s.cropperFrame, display: true)
        contentWindow.setFrame(s.contentFrame, display: true)
    }
    
    @AppStorage(ContentLayoutKey) private var contentLayout: Int = ContentLayout.portrait.rawValue
    @AppStorage(PortraitCornerKey) private var portraitCorner: Int = PortraitCorner.topTrailing.rawValue
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 100.0
    @AppStorage(LandscapeStyleKey) private var landscapeStyle: Int = LandscapeStyle.normal.rawValue
    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 160.0

    @AppStorage(ContentPaddingStyleKey) var contentPaddingStyle: Int = ContentPaddingStyle.standard.rawValue
    @AppStorage(StandardCornerRadiusKey) private var standardCornerRadius: Double = 6.0
    @AppStorage(MinimalistVPaddingKey) var minimalistVPadding: Double = 2.0
    @AppStorage(MinimalistHPaddingKey) var minimalistHPadding: Double = 6.0

    @AppStorage(FontSizeKey) private var fontSize: Int = 14
    @AppStorage(LineSpacingKey) private var lineSpacing: Double = 0

    @AppStorage(CropperStyleKey) private var cropperStyle: Int = CropperStyle.empty.rawValue

    @AppStorage(MaximumFrameRateKey) private var maximumFrameRate: Double = 4
    @AppStorage(TRTextRecognitionLevelKey) var tRTextRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    @AppStorage(TRMinimumTextHeightKey) var tRMinimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315

    @AppStorage(LemmaSearchLevelKey) private var lemmaSearchLevel: Int = LemmaSearchLevel.database.rawValue

    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    @AppStorage(IsAddSpaceKey) private var isAddSpace: Bool = false

    @AppStorage(HighlightModeKey) var highlightMode: Int = HighlightMode.dotted.rawValue
    @AppStorage(HLRectangleColorKey) private var hLRectangleColor: Data = colorToData(NSColor.red.withAlphaComponent(0.15))!
    @AppStorage(StrokeDownwardOffsetKey) var strokeDownwardOffset: Double = 5.0
    @AppStorage(StrokeLineWidthKey) var strokeLineWidth: Double = 1.6
    @AppStorage(StrokeDashPaintedKey) var strokeDashPainted: Double = 1.0
    @AppStorage(StrokeDashUnPaintedKey) var strokeDashUnPainted: Double = 3.0
    @AppStorage(IndexPaddingKey) var indexPadding: Double = 2.0
    @AppStorage(IndexFontSizeKey) var indexFontSize: Int = 7
    @AppStorage(IsAlwaysRefreshHighlightKey) var isAlwaysRefreshHighlight: Bool = false
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
                    get: { slot.label! },
                    set: { newValue in
                        slot.label = newValue
                        saveContext()
                    }
                ))
                    .font(.callout)
                    .textFieldStyle(PlainTextFieldStyle())
            }
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
        HStack {
            Button(action: add) {
                Image(systemName: "plus")
            }
            
            HStack {
                Button(action: delete) {
                    Image(systemName: "minus")
                }
                
                Button(action: clone) {
                    Image(systemName: "doc.on.clipboard")
                }
                
                Button(action: up) {
                    Image(systemName: "arrowtriangle.up")
                }
                
                Button(action: down) {
                    Image(systemName: "arrowtriangle.down")
                }
            }
            .disabled(selectedSlot == nil)

            Button(action: clear) {
                Image(systemName: "trash")
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
                .environment(\.managedObjectContext, persistentContainer.viewContext)

//            InfoView()
        }
//        .environment(\.locale, .init(identifier: "zh-Hant"))
        .environment(\.locale, .init(identifier: "en"))
    }
}
