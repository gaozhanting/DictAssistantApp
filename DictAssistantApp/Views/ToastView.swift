//
//  ToastView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/29.
//

import SwiftUI

fileprivate struct ToastView: View {
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
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

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
                }
            }
            
            Image(imageSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)
            
            Text(info)
                .font(.system(size: 30, weight: .regular))
        }
        .foregroundColor(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VisualEffectView(material: .underWindowBackground))
    }
}

struct ToastOnView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        ToastView(imageSystemName: "FullToast", info: "ON")
            .environment(\.colorScheme, colorScheme)
    }
}

struct ToastOffView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        ToastView(imageSystemName: "EmptyToast", info: "OFF")
            .environment(\.colorScheme, colorScheme)
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
