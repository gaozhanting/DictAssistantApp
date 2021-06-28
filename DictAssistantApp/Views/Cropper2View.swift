//
//  Cropper2View.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/28.
//

import SwiftUI

struct Cropper2View: View {
    var body: some View {
        Rectangle()
            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
}

struct Cropper2View_Previews: PreviewProvider {
    static var previews: some View {
        Cropper2View()
    }
}
