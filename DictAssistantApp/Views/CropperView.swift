//
//  CropperView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/28.
//

import SwiftUI

struct StrokeBorderCropperView: View {
    var body: some View {
        Rectangle()
            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}

struct RectCropperView: View {
    var body: some View {
        Spacer()
            .help("Cropper")
            .background(Color.black.opacity(0.35))
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
        EmptyView()

    }
}

struct CropperView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StrokeBorderCropperView()
            RectCropperView()
            MiniCropperView()
            ClosedCropperView()
        }
    }
}
