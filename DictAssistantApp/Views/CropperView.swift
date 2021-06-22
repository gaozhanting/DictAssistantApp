//
//  CropView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/23.
//

import SwiftUI

struct CropperView: View {
    @EnvironmentObject var statusData: StatusData
    var isPlaying: Bool {
        statusData.isPlaying
    }
    
    @EnvironmentObject var visualConfig: VisualConfig

    @EnvironmentObject var cropData: CropData
    
    @GestureState private var startLocation: CGPoint? = nil
    @GestureState private var startWidth: CGFloat? = nil
    @GestureState private var startHeight: CGFloat? = nil

    private let mSize: CGFloat = 16
    private let sSize: CGFloat = 12
    private let sOffset: CGFloat = 4
    private let minWidth: CGFloat = 50.0
    private let minHeight: CGFloat = 20.0
    
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
            .opacity(0) // this will make curtain not response to the cursor scroll event
    }
    
    // Runtime Warning: Invalid frame dimension (negative or non-finite).
    var cropper: some View {
        Rectangle()
            .opacity(0) // this will make cropper not response to the cursor scroll event
            .frame(width: cropData.width, height: cropData.height)
            .overlay( // this will add a stoke border of cropper
                Rectangle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                    .foregroundColor(.green)
                    .opacity(visualConfig.showStrokeBorder ? 1 : 0)
            )
            
            .overlay(
                Rectangle()
                    .opacity(0.005)
                    .frame(width: mSize, height: mSize)
                    .gesture(sealedMove),
                alignment: .bottomLeading)
            .overlay(
                Rectangle()
                    .fill(Color.purple)
//                    .opacity(0.005)
                    .frame(width: mSize, height: mSize)
                    .border(Color.pink)
                    .gesture(sealedMove)
                ,
                alignment: .bottomTrailing)
            .overlay(
                Rectangle()
                    .fill(Color.purple)
//                    .opacity(0.005)
                    .frame(width: mSize, height: mSize)
                    .border(Color.pink)
                    .gesture(sealedMove)
                ,
                alignment: .topLeading
            )
            .overlay(
                Rectangle()
                    .opacity(0.005)
                    .frame(width: mSize, height: mSize)
                    .gesture(sealedMove),
                alignment: .topTrailing)
            
            
            .overlay(
                Rectangle()
                    .opacity(0.005)
                    .frame(width: sSize, height: sSize)
                    .offset(x: -sOffset, y: sOffset)
                    .gesture(isPlaying ? nil : scale(-1, 1)),
                alignment: .bottomLeading)
            .overlay(
                Rectangle()
                    .fill(Color.blue)
//                    .opacity(0.005)
                    .frame(width: sSize, height: sSize)
                    .border(Color.yellow)
                    .offset(x: sOffset, y: sOffset)
                    .gesture(isPlaying ? nil : scale(1, 1)),
                alignment: .bottomTrailing)
            .overlay(
                Rectangle()
                    .fill(Color.blue)
//                    .opacity(0.005)
                    .frame(width: sSize, height: sSize)
                    .border(Color.yellow)
                    .offset(x: -sOffset, y: -sOffset)
                    .gesture(isPlaying ? nil : scale(-1, -1)),
                alignment: .topLeading)
            .overlay(
                Rectangle()
                    .opacity(0.005)
                    .frame(width: sSize, height: 15)
                    .offset(x: sOffset, y: -sOffset)
                    .gesture(isPlaying ? nil : scale(1, -1)),
                alignment: .topTrailing)
            
            .position(CGPoint(x: cropData.x, y: cropData.y))
    }
    
    var info: some View {
        VStack {
            Text("Location: \(Int(cropData.x)), \(Int(cropData.y))")
            Text("WH: \(Int(cropData.width)), \(Int(cropData.height))")
        }
        .background(Color.yellow)
        .frame(width: 300, height: 120)
    }
    
    func scale(_ i: CGFloat, _ j: CGFloat) -> some Gesture {
        DragGesture(coordinateSpace: .named("stack"))
            .onChanged { value in
                var newWidth = startWidth ?? cropData.width
                var realTranslationWidth = i * value.translation.width
                if (newWidth + realTranslationWidth) < minWidth {
                    realTranslationWidth = minWidth - newWidth
                }
                newWidth += realTranslationWidth

                var newHeight = startHeight ?? cropData.height
                var realTranslationHeight = j * value.translation.height
                if (newHeight + realTranslationHeight) < minHeight {
                    realTranslationHeight = minHeight - newHeight
                }
                newHeight += realTranslationHeight

                var newPosition = startLocation ?? CGPoint(x: cropData.x, y: cropData.y)
                newPosition.x += 0.5 * realTranslationWidth * i
                newPosition.y += 0.5 * realTranslationHeight * j

                cropData.width = newWidth
                cropData.height = newHeight
                cropData.x = newPosition.x
                cropData.y = newPosition.y
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
    
    var sealedMove: some Gesture {
        isPlaying ? nil : move
    }
    
    var move: some Gesture {
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
    static var previews: some View {
        CropperView().environmentObject(CropData(
            x: 300.0,
            y: 300.0,
            width: 300.0,
            height: 100.0
        ))
    }
}
