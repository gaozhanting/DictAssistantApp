//
//  ToastView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/29.
//

import SwiftUI

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

private struct ToastView: View {
    @AppStorage(TheColorSchemeKey) var theColorScheme: Int = TheColorScheme.system.rawValue

    let imageSystemName: String
    let info: String
    
    var body: some View {
        VStack {
            GroupBox {
                SelectedSlotView(imageFont: .largeTitle, textFont: .title2)
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
        .shadow(color: .primary, radius: 3)
        .foregroundColor(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VisualEffectView(material: .underWindowBackground))
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
