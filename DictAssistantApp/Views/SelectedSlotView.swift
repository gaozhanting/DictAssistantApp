//
//  SelectedSlotView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2022/11/2.
//

import SwiftUI

struct SelectedSlotView: View {
    let imageFont: Font
    let textFont: Font
    
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
        Group { // here, need Group
            if let slot = selectedSlot {
                HStack {
                    Image(systemName: "shippingbox.circle.fill")
                        .font(imageFont)
                        .foregroundColor(Color(dataToColor(slot.color!)!))
                    
                    Text(slot.label!)
                        .font(textFont)
                        .lineLimit(1)
                        .foregroundColor(Color(NSColor.labelColor))
                }
                .shadow(color: .primary, radius: 1)
            } else {
                EmptyView()
            }
        }
    }
}

struct SelectedSlotView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedSlotView(imageFont: .title, textFont: .callout)
            .environment(\.managedObjectContext, persistentContainer.viewContext)
    }
}
