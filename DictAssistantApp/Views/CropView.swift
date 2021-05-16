//
//  CropView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/16.
//

import SwiftUI

struct CropView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .overlay(
                    view2
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @State private var position: CGPoint = CGPoint(x: 0, y: 0)
    
    var overlay: some View {
        Rectangle()
            .position(position)
            .foregroundColor(.red)
            .frame(width: 300, height: 100, alignment: .center)
//            .shadow(color: .red, radius: 5, x: 3, y: 10)
            .gesture(
                DragGesture()
                    .onChanged({ gesture in
                        position = gesture.location
                    })
//                    .onEnded({ gesture in
//                        position = gesture.startLocation
//                    })
            )
//            .scaleEffect(2, anchor: .leading)
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
    }
    
    var view2: some View {
        ZStack {
            VStack {
                Text("SwiftUI for iOS 14")
                    .bold()
            }
            .frame(width: 300, height: 200)
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
        }
    }
}

struct CropView_Previews: PreviewProvider {
    static var previews: some View {
        CropView()
    }
}
