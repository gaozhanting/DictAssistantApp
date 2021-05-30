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
    
    @State private var width: CGFloat = 400
    @State private var height: CGFloat = 200
    @GestureState private var startWidth: CGFloat? = nil
    
    var info: some View {
        VStack {
            Text("Location: \(Int(location.x)), \(Int(location.y))")
            Text("WH: \(Int(width)), \(Int(height))")
        }
        .background(Color.yellow)
        .frame(width: 300, height: 120)
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
            curtain
            cropper
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "stack")
    }
    
    var curtain: some View {
        Rectangle()
            .fill(Color.gray)
            .opacity(0)
    }
    
    // Runtime Warning: Invalid frame dimension (negative or non-finite).
    var cropper: some View {
        Rectangle()
            .border(Color.orange, width: 1)
            .frame(width: width, height: height)
            .overlay(info, alignment: .bottom)
            .onHover { hovered in
                if hovered {
                    NSCursor.openHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            }
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
                var newWidth = startWidth ?? width

                if cursorNearbyRightEdgeOfRectangle() {
                    newWidth += value.translation.width
                    width = newWidth
                    return
                }
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location
            }
            .updating($startWidth) { (value, startWidth, transaction) in
                startWidth = startWidth ?? width
            }
    }
}

struct CropView_Previews: PreviewProvider {
    static var previews: some View {
        CropperView()
    }
}
