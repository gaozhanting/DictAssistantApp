//
//  CropperView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/28.
//

import SwiftUI

struct RectCropperView: View {
    var body: some View {
        Spacer()
            .help("Cropper")
            .background(Color.black.opacity(0.25))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}

struct MiniCropperView: View {
    var body: some View {
        Spacer()
            .overlay(
                Text("x"),
                alignment: .topLeading
            )
            .help("Cropper")
            .background(Color.black.opacity(0))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}

struct ClosedCropperView: View {
    var body: some View {
        Spacer()
            .help("Cropper")
            .background(Color.black.opacity(0))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}

//struct Cropper2View_Previews: PreviewProvider {
//    static var previews: some View {
////        CropperView()
//    }
//}
