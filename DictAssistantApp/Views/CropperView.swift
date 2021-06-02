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
//            .fill(Color.gray)
            .opacity(0) // this will make curtain not response to the cursor scroll event
    }
    
    // Runtime Warning: Invalid frame dimension (negative or non-finite).
    var cropper: some View {
        Rectangle()
//            .fill(Color.secondary)
            .opacity(0) // this will make cropper not response to the cursor scroll event
            .frame(width: cropData.width, height: cropData.height)
            .overlay( // this will add a stoke border of cropper
                Rectangle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [2]))
            )
//            .onHover { hovered in // not works
//                if hovered {
//                    NSCursor.openHand.set()
//                } else {
//                    NSCursor.arrow.set()
//                }
//            }
//            .overlay(info, alignment: .center) // for test ?!
            .overlay(
                Rectangle()
//                    .opacity(0.01)
                    .frame(width: 25, height: 25)
                    .foregroundColor(.green)
                    .border(Color.red)
                    .gesture(move),
                alignment: .bottomTrailing)
            .overlay(
                Rectangle()
//                    .opacity(0.01)
                    .frame(width: 15, height: 15)
                    .foregroundColor(.blue)
                    .border(Color.red)
                    .offset(x: 8, y: 8)
                    .gesture(scale),
                alignment: .bottomTrailing)
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
    
    private let minWidth: CGFloat = 100.0
    private let minHeight: CGFloat = 50.0
    
    var scale: some Gesture {
        DragGesture(coordinateSpace: .named("stack"))
            .onChanged { value in
                var newWidth = startWidth ?? cropData.width
                var realTranslationWidth = value.translation.width
                if (newWidth + realTranslationWidth) < minWidth {
                    realTranslationWidth = minWidth - newWidth
                }
                newWidth += realTranslationWidth

                var newHeight = startHeight ?? cropData.height
                var realTranslationHeight = value.translation.height
                if (newHeight + realTranslationHeight) < minHeight {
                    realTranslationHeight = minHeight - newHeight
                }
                newHeight += realTranslationHeight

                var newPosition = startLocation ?? CGPoint(x: cropData.x, y: cropData.y)
                newPosition.x += 0.5 * realTranslationWidth
                newPosition.y += 0.5 * realTranslationHeight

                cropData.width = newWidth
                cropData.height = newHeight
                cropData.x = newPosition.x
                cropData.y = newPosition.y
                
//                print("scale> x:\(cropData.x), y:\(cropData.y), width:\(cropData.width), height:\(cropData.height)")
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
    
    var move: some Gesture {
        DragGesture(coordinateSpace: .named("stack"))
            .onChanged { value in
                var newPosition = startLocation ?? CGPoint(x: cropData.x, y: cropData.y)
                newPosition.x += value.translation.width
                newPosition.y += value.translation.height
                cropData.x = newPosition.x
                cropData.y = newPosition.y
                
//                print("move> x:\(cropData.x), y:\(cropData.y), width:\(cropData.width), height:\(cropData.height)")
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
