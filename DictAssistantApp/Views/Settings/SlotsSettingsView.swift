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
                        ItemView(slot: slot, slots: slots)
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
}

private struct ItemView: View {
    let slot: Slot
    let slots: FetchedResults<Slot>
        
    func select(_ slot: Slot) -> Void {
        for slot in slots {
            slot.isSelected = false
        }
        slot.isSelected = true
        saveContext()
        tRTextRecognitionLevel = Int(slot.tRTextRecognitionLevel)
        tRMinimumTextHeight = slot.tRMinimumTextHeight
        // ...
    }
    
    var body: some View {
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
    
    @AppStorage(TRTextRecognitionLevelKey) var tRTextRecognitionLevel: Int = VNRequestTextRecognitionLevel.fast.rawValue // fast 1, accurate 0
    @AppStorage(TRMinimumTextHeightKey) var tRMinimumTextHeight: Double = systemDefaultMinimumTextHeight // 0.0315
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
                slot.tRTextRecognitionLevel = Int64(VNRequestTextRecognitionLevel.fast.rawValue)
                slot.tRMinimumTextHeight = systemDefaultMinimumTextHeight
                // ...
                slot.createdDate = Date()
                slot.isSelected = false
                saveContext()
            }
            
            Button("Clone") {
                if let selectedSlot = selectedSlot {
                    let slot = Slot(context: managedObjectContext)
                    slot.color = colorToData(NSColor.random())
                    slot.label = "\(selectedSlot.label ?? "") cloned"
                    slot.tRTextRecognitionLevel = selectedSlot.tRTextRecognitionLevel
                    slot.tRMinimumTextHeight = selectedSlot.tRMinimumTextHeight
                    // ...
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
