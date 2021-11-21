//
//  ToastView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/29.
//

import SwiftUI

private struct ToastView: View {
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
    
    @AppStorage(TheColorSchemeKey) private var theColorScheme: Int = TheColorScheme.system.rawValue

    let imageSystemName: String
    let info: String
    
    var body: some View {
        VStack {
            if let slot = selectedSlot {
                HStack {
                    Image(systemName: "cube.fill")
                        .font(.largeTitle)
                        .foregroundColor(Color(dataToColor(slot.color!)!))
                    
                    Text(slot.label!)
                        .font(.title2)
                        .lineLimit(1)
                        .foregroundColor(Color(NSColor.labelColor))
                }
                .padding(.horizontal)
            }
            
            Image(imageSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)
            
            Text(info)
                .font(.largeTitle)
                .foregroundColor(Color(NSColor.labelColor))
        }
        .foregroundColor(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VisualEffectView(material: .underWindowBackground))
    }
}

struct ToastOnView: View {
    var body: some View {
        ToastView(imageSystemName: "FullToast", info: "ON")
    }
}

struct ToastOffView: View {
    var body: some View {
        ToastView(imageSystemName: "EmptyToast", info: "OFF")
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToastOnView()
            ToastOffView()
        }
        .frame(maxWidth: 300, maxHeight: 300)
        .environment(\.managedObjectContext, persistentContainer.viewContext)
    }
}
