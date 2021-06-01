//
//  CropView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/23.
//

import SwiftUI

struct CropperView: View {
    @ObservedObject var cropData: CropData
    
    @GestureState private var startLocation: CGPoint? = nil
    @GestureState private var startWidth: CGFloat? = nil
    @GestureState private var startHeight: CGFloat? = nil

    
    var info: some View {
        VStack {
            Text("Location: \(Int(cropData.x)), \(Int(cropData.y))")
            Text("WH: \(Int(cropData.width)), \(Int(cropData.height))")
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
        .edgesIgnoringSafeArea(.top)
    }
    
    var curtain: some View {
        Rectangle()
            .fill(Color.gray)
            .opacity(0)
    }
    
    // Runtime Warning: Invalid frame dimension (negative or non-finite).
    var cropper: some View {
        Rectangle()
            .fill(Color.secondary)
            .opacity(0.01)
//            .border(Color.secondary, width: 0.3)
            .frame(width: cropData.width, height: cropData.height)
            .overlay(
                Rectangle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(.primary)
            )
            .onHover { hovered in
                if hovered {
                    NSCursor.openHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            }
//            .overlay(info, alignment: .center) // for test ?!
            .overlay(
                Circle()
                    .opacity(0.01)
                    .frame(width: 30, height: 30)
//                    .foregroundColor(.blue)
//                    .border(Color.green)
                    .offset(x: 5, y: 5)
                    .gesture(resizeDragGesture),
                alignment: .bottomTrailing)
            .position(CGPoint(x: cropData.x, y: cropData.y))
            .gesture(drag)

    }
    
//    func cursorNearbyRightEdgeOfRectangle() -> Bool {
//        return true
//    }
    
    var resizeDragGesture: some Gesture {
        DragGesture(coordinateSpace: .named("stack"))
            .onChanged { value in
                var newPosition = startLocation ?? CGPoint(x: cropData.x, y: cropData.y)
                newPosition.x += 0.5 * value.translation.width
                newPosition.y += 0.5 * value.translation.height
                cropData.x = newPosition.x
                cropData.y = newPosition.y
            }
            .onChanged { value in
                var newWidth = startWidth ?? cropData.width
                newWidth += value.translation.width
                cropData.width = newWidth
            }
            .onChanged { value in
                var newHeight = startHeight ?? cropData.height
                newHeight += value.translation.height
                cropData.height = newHeight
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? CGPoint(x: cropData.x, y: cropData.y)
            }
            .updating($startWidth) { (value, startWidth, transaction) in
                startWidth = startWidth ?? cropData.width
            }
            .updating($startHeight) { (value, startHeight, transaction) in
                startHeight = startHeight ?? cropData.height
            }
    }
    
    var drag: some Gesture {
        DragGesture(coordinateSpace: .named("stack"))
            .onChanged { value in
                var newPosition = startLocation ?? CGPoint(x: cropData.x, y: cropData.y)
                newPosition.x += value.translation.width
                newPosition.y += value.translation.height
                cropData.x = newPosition.x
                cropData.y = newPosition.y
            }
            .updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? CGPoint(x: cropData.x, y: cropData.y)
            }
    }
}

struct CropView_Previews: PreviewProvider {
    static let cropData = CropData()
    static var previews: some View {
        CropperView(cropData: cropData)
    }
}
