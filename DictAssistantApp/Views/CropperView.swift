//
//  CropView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/23.
//

import SwiftUI

struct CropperView: View {
    @State private var location = CGPoint(x: 400, y: 200)
    @GestureState private var startLocation: CGPoint? = nil
//    @State private var sw: CGFloat = 0
    @GestureState private var w: CGFloat? = nil
    
    @State private var width: CGFloat = 400
    @State private var height: CGFloat = 200

    var body: some View {
        ZStack {
            curtain
            cropper
            VStack {
                Text("Location: \(Int(location.x)), \(Int(location.y))")
                Text("WH: \(Int(width)), \(Int(height))")
            }
        }
        .opacity(0.7)
        .frame(width: 800, height: 400)
        .coordinateSpace(name: "stack")
    }
    
    var curtain: some View {
        Rectangle()
            .fill(Color.gray)
    }
    
    // Runtime Warning: Invalid frame dimension (negative or non-finite).
    var cropper: some View {
        Rectangle()
            .border(Color.orange, width: 1)
            .frame(width: width, height: height)
            .position(location)
            .gesture(drag)
    }
    
    func cursorNearbyRightEdgeOfRectangle() -> Bool {
        return true
    }
    
    var drag: some Gesture {
        DragGesture(coordinateSpace: .named("stack"))
            .onChanged { value in
                var newPosition = startLocation ?? location

                if cursorNearbyRightEdgeOfRectangle() {
                    newPosition.x += 0.5 * value.translation.width
                    location = newPosition
                    return
                }
                
                newPosition.x += value.translation.width
                newPosition.y += value.translation.height
                location = newPosition
            }
            .onChanged { value in
                var newWidth = w ?? width

                if cursorNearbyRightEdgeOfRectangle() {
                    newWidth += value.translation.width
                    width = newWidth
                    return
                }
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location
            }
            .updating($w) { (value, w, transaction) in
                w = w ?? width
            }
    }
}

struct CropView_Previews: PreviewProvider {
    static var previews: some View {
        CropperView()
    }
}
