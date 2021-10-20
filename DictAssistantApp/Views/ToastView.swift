//
//  ToastView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/29.
//

import SwiftUI

fileprivate struct ToastView: View {
    let imageSystemName: String
    let info: String
    
    var body: some View {
        VStack {
            Image(imageSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Text(info)
                .font(.system(size: 30, weight: .regular))
        }
        .foregroundColor(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            VisualEffectView(material: .underWindowBackground)
                .preferredColorScheme(.dark)
        )
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
    }
}
