//
//  CropView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/23.
//

import SwiftUI

struct CropperView: View {
    @State private var location = CGPoint(x: 200, y: 200)
    @GestureState private var startLocation: CGPoint? = nil
    
    @State private var width: CGFloat = 400
    @State private var height: CGFloat = 300

    var body: some View {
        ZStack {
            curtain
            cropper
            Text("Location: \(Int(location.x)), \(Int(location.y))")
        }
        .opacity(0.7)
        .frame(width: 700, height: 700)
        .coordinateSpace(name: "stack")
    }
    
    var curtain: some View {
        Rectangle()
            .fill(Color.gray)
    }
    
    var cropper: some View {
        Rectangle()
            .border(Color.orange, width: 1)
            .frame(width: width, height: height)
            .position(location)
            .gesture(drag)
    }
    
    var drag: some Gesture {
        DragGesture(coordinateSpace: .named("stack"))
            .onChanged { value in
                var newPosition = startLocation ?? location
                newPosition.x += value.translation.width
                newPosition.y += value.translation.height
                location = newPosition
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location
            }
    }
}

struct CropView_Previews: PreviewProvider {
    static var previews: some View {
        CropperView()
    }
}
